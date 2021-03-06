/** Implementation for NSTask for GNUStep
   Copyright (C) 1998,1999 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
   Date: 1998

   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.

   <title>NSTask class reference</title>
   $Date: 2010-09-17 13:23:48 -0700 (Fri, 17 Sep 2010) $ $Revision: 31366 $
 */

#import "common.h"
#define EXPOSE_NSTask_IVARS 1
#import "Foundation/NSAutoreleasePool.h"
#import "Foundation/NSBundle.h"
#import "Foundation/NSCharacterSet.h"
#import "Foundation/NSData.h"
#import "Foundation/NSDate.h"
#import "Foundation/NSEnumerator.h"
#import "Foundation/NSException.h"
#import "Foundation/NSFileHandle.h"
#import "Foundation/NSFileManager.h"
#import "Foundation/NSMapTable.h"
#import "Foundation/NSProcessInfo.h"
#import "Foundation/NSRunLoop.h"
#import "Foundation/NSNotification.h"
#import "Foundation/NSNotificationQueue.h"
#import "Foundation/NSTask.h"
#import "Foundation/NSThread.h"
#import "Foundation/NSTimer.h"
#import "Foundation/NSLock.h"
#import "GNUstepBase/NSString+GNUstepBase.h"
#import "GNUstepBase/NSObject+GNUstepBase.h"
#import "GSPrivate.h"

#include <string.h>
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif
#include <sys/types.h>
#ifdef __FreeBSD__
#include <fcntl.h>
#endif

#ifdef HAVE_WINDOWS_H
#  include <windows.h>
#endif

#ifdef  HAVE_SYS_SIGNAL_H
#include <sys/signal.h>
#endif
#ifdef  HAVE_SIGNAL_H
#include <signal.h>
#endif
#ifdef  HAVE_SYS_FILE_H
#include <sys/file.h>
#endif
#ifdef  HAVE_SYS_FCNTL_H
#include <sys/fcntl.h>
#endif
#ifdef  HAVE_SYS_IOCTL_H
#include <sys/ioctl.h>
#endif
#ifdef  HAVE_SYS_WAIT_H
#include <sys/wait.h>
#endif
#ifdef  HAVE_SYS_PARAM_H
#include <sys/param.h>
#endif


/*
 *	If we are on a streams based system, we need to include stropts.h
 *	for definitions needed to set up slave pseudo-terminal stream.
 */
#ifdef  HAVE_SYS_STROPTS_H
#include <sys/stropts.h>
#endif

#ifndef MAX_OPEN
#define MAX_OPEN    64
#endif

/*
 *	If we don't have NFILE, default to 256 open descriptors.
 */
#ifndef NOFILE
#define NOFILE  256
#endif


@interface  NSBundle (Private)
+ (NSString *)_absolutePathOfExecutable:(NSString *)path;
+ (NSString*)_gnustep_target_cpu;
+ (NSString*)_gnustep_target_dir;
+ (NSString*)_gnustep_target_os;
+ (NSString*)_library_combo;
@end

static NSRecursiveLock  *tasksLock = nil;
static NSMapTable       *activeTasks = 0;

static BOOL hadChildSignal = NO;
static void handleSignal(int sig)
{
    hadChildSignal = YES;
    signal(SIGCHLD, handleSignal);
}

@interface NSConcreteUnixTask : NSTask
{
    char slave_name[32];
    BOOL _usePseudoTerminal;
}
@end
#define NSConcreteTask NSConcreteUnixTask

static int
pty_master(char* name, int len)
{
    int master;

    /*
     *	If we have grantpt(), assume we are using sysv-style pseudo-terminals,
     *	otherwise assume bsd style.
     */
#ifdef  HAVE_GRANTPT
    master = open("/dev/ptmx", O_RDWR);
    if (master >= 0)
    {
        const char    *slave;

        grantpt(master);                 /* Change permission of slave.  */
        unlockpt(master);                /* Unlock slave.        */
        slave = (const char*)ptsname(master);
        if (slave == 0 || strlen(slave) >= len)
        {
            close(master);
            master = -1;
        }
        else
        {
            strcpy(name, (char*)slave);
        }
    }
    else
#endif
    {
        const char    *groups = "pqrstuvwxyzPQRSTUVWXYZ";

        master = -1;
        if (len > 10)
        {
            strcpy(name, "/dev/ptyXX");
            while (master < 0 && *groups != '\0')
            {
                int i;

                name[8] = *groups++;
                for (i = 0; i < 16; i++)
                {
                    name[9] = "0123456789abcdef"[i];
                    master = open(name, O_RDWR);
                    if (master >= 0)
                    {
                        name[5] = 't';
                        break;
                    }
                }
            }
        }
    }
    return master;
}

static int
pty_slave(const char* name)
{
    int slave;

    slave = open(name, O_RDWR);
#ifdef  HAVE_SYS_STROPTS_H
#ifdef  HAVE_PTS_STREAM_MODULES
    if (slave >= 0 && isastream(slave))
    {
        if (ioctl(slave, I_PUSH, "ptem") < 0)
        {
            perror("unable to push 'ptem' streams module");
        }
        else if (ioctl(slave, I_PUSH, "ldterm") < 0)
        {
            perror("unable to push 'ldterm' streams module");
        }
    }
#endif
#endif
    return slave;
}


@interface NSTask (Private)
- (NSString *)_fullLaunchPath;
- (void)_collectChild;
- (void)_terminatedChild:(int)status;
@end


/**
 * The NSTask class provides a mechanism to run separate tasks
 * under (limited) control of your program.
 */
@implementation NSTask

+ (id)allocWithZone:(NSZone*)zone
{
    NSTask *task;

    if (self == [NSTask class]) {
        task = (NSTask *)NSAllocateObject([NSConcreteTask class], 0, zone);
    }
    else{
        task = (NSTask *)NSAllocateObject(self, 0, zone);
    }
    return task;
}

+ (void)initialize
{
    if (self == [NSTask class])
    {
        [gnustep_global_lock lock];
        if (tasksLock == nil)
        {
            tasksLock = [NSRecursiveLock new];
            /* The activeTasks map contains the NSTask objects corresponding
             * to running subtasks, and retains them until the subprocess
             * actually terminates.
             * The previous implementation stored non-retained objects and
             * the -finalize method removed them from the table, but this
             * caused a thread safety issue even though table access was
             * lock protected:
             * If thread t1 releases the task at the same time that the subtask
             * dies and is 'reaped' by t2, then there is a window such
             * that t1 can enter -dealloc while t2 is dealing with
             * subprocess termination notification.
             * So t1 completes deallocation while t2 performs
             * the notification, and then t2 tries to release the object...
             * t1: enter dealloc
             * t2: lookup task in activeTasks and retain/autorelease it
             * t2: create NSNotification (retaining task)
             * t2: post notification
             * t1: remove task from activeTasks
             * t1: release memory occupied by task object.
             * t2: complete notification ... attempt to release task object
             * but it's already deallocated.
             */
            activeTasks = NSCreateMapTable(NSIntMapKeyCallBacks,
                                           NSObjectMapValueCallBacks, 0);
        }
        [gnustep_global_lock unlock];

        signal(SIGCHLD, handleSignal);
    }
}

/**
 * Creates and launches a task, returning an autoreleased task object.
 * Supplies the path to the executable and an array of argument.
 * The task inherits the parents environment and I/O.
 */
+ (NSTask*)launchedTaskWithLaunchPath:(NSString*)path
    arguments:(NSArray*)args
{
    NSTask*   task = [NSTask new];

    [task setLaunchPath:path];
    [task setArguments:args];
    [task launch];
    return AUTORELEASE(task);
}

- (void)finalize
{
    return;
}

- (void)dealloc
{
    [self finalize];
    RELEASE(_arguments);
    RELEASE(_environment);
    RELEASE(_launchPath);
    RELEASE(_currentDirectoryPath);
    RELEASE(_standardError);
    RELEASE(_standardInput);
    RELEASE(_standardOutput);
    [super dealloc];
}

/**
 * Returns the arguments set for the task.
 */
- (NSArray*)arguments
{
    return _arguments;
}

/**
 * Returns the working directory set for the task.
 */
- (NSString*)currentDirectoryPath
{
    if (_currentDirectoryPath == nil)
    {
        [self setCurrentDirectoryPath:
         [[NSFileManager defaultManager] currentDirectoryPath]];
    }
    return _currentDirectoryPath;
}

/**
 * Returns the environment set for the task.
 */
- (NSDictionary*)environment
{
    if (_environment == nil)
    {
        [self setEnvironment:[[NSProcessInfo processInfo] environment]];
    }
    return _environment;
}

/**
 * Sends an interrupt signal to the receiver and any subtasks.<br />
 * If the task has not been launched, raises an
 * NSInvalidArgumentException.<br />
 * Has no effect on a task that has already terminated.<br />
 * This is rather like the terminate method, but the child
 * process may not choose to terminate in response to an interrupt.
 */
- (void)interrupt
{
    if (_hasLaunched == NO)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - task has not yet launched"];
    }
    if (_hasTerminated)
    {
        return;
    }

#ifdef  HAVE_KILLPG
    killpg(_taskId, SIGINT);
#else
    kill(-_taskId, SIGINT);
#endif
}

/**
 * Checks to see if the task is currently running.
 */
- (BOOL)isRunning
{
    if (_hasLaunched == NO)
    {
        return NO;
    }
    if (_hasCollected == NO)
    {
        [self _collectChild];
    }
    if (_hasTerminated == YES)
    {
        return NO;
    }
    return YES;
}

/**
 * Launches the task.<br />
 * Raises an NSInvalidArgumentException if the launch path is not
 * set or if the subtask cannot be started for some reason
 * (eg. the executable does not exist or the task has already been launched).
 */
- (void)launch
{
    [self subclassResponsibility:_cmd];
}

/**
 * Returns the launch path set for the task.
 */
- (NSString*)launchPath
{
    return _launchPath;
}

/**
 * Returns the number identifying the child process on this system.
 */
- (int)processIdentifier
{
    return _taskId;
}

/**
 * Sends a cont signal to the receiver and any subtasks.<br />
 * If the task has not been launched, raises an
 * NSInvalidArgumentException.<br />
 */
- (BOOL)resume
{
    if (_hasLaunched == NO)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - task has not yet launched"];
    }
#ifdef  HAVE_KILLPG
    killpg(_taskId, SIGCONT);
#else
    kill(-_taskId, SIGCONT);
#endif
    return YES;
}

/**
 * Sets an array of arguments to be supplied to the task when it
 * is launched.  The default is an empty array.  This method cannot
 * be used after a task is launched ...
 * it raises an NSInvalidArgumentException.
 */
- (void)setArguments:(NSArray*)args
{
    if (_hasLaunched)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - task has been launched"];
    }
    ASSIGN(_arguments, args);
}

/**
 * Sets the home directory in which the task is to be run.
 * The default is the parent processes directory.
 * This method cannot be used after a task is launched ...
 * it raises an NSInvalidArgumentException.
 */
- (void)setCurrentDirectoryPath:(NSString*)path
{
    if (_hasLaunched)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - task has been launched"];
    }
    ASSIGN(_currentDirectoryPath, path);
}

/**
 * Sets the environment variables for the task to be run.
 * The default is the parent processes environment.
 * This method cannot be used after a task is launched ...
 * it raises an NSInvalidArgumentException.
 */
- (void)setEnvironment:(NSDictionary*)env
{
    if (_hasLaunched)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - task has been launched"];
    }
    ASSIGN(_environment, env);
}

/**
 * Sets the path to the executable file to be run.
 * There is no default for this - you must set the launch path.
 * This method cannot be used after a task is launched ...
 * it raises an NSInvalidArgumentException.
 */
- (void)setLaunchPath:(NSString*)path
{
    if (_hasLaunched)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - task has been launched"];
    }
    ASSIGN(_launchPath, path);
}

/**
 * Sets the standard error stream for the task.<br />
 * This is normally a writable NSFileHandle object.
 * If this is an NSPipe, the write end of the pipe is
 * automatically closed on launching.<br />
 * The default behavior is to inherit the parent processes
 * stderr output.<br />
 * This method cannot be used after a task is launched ...
 * it raises an NSInvalidArgumentException.
 */
- (void)setStandardError:(id)hdl
{
    if (_hasLaunched)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - task has been launched"];
    }
    NSAssert(hdl != nil && ([hdl isKindOfClass:[NSFileHandle class]] ||
                            [hdl isKindOfClass:[NSPipe class]]), NSInvalidArgumentException);
    ASSIGN(_standardError, hdl);
}

/**
 * Sets the standard input stream for the task.<br />
 * This is normally a readable NSFileHandle object.
 * If this is an NSPipe, the read end of the pipe is
 * automatically closed on launching.<br />
 * The default behavior is to inherit the parent processes
 * stdin stream.<br />
 * This method cannot be used after a task is launched ...
 * it raises an NSInvalidArgumentException.
 */
- (void)setStandardInput:(id)hdl
{
    if (_hasLaunched)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - task has been launched"];
    }
    NSAssert(hdl != nil && ([hdl isKindOfClass:[NSFileHandle class]] ||
                            [hdl isKindOfClass:[NSPipe class]]), NSInvalidArgumentException);
    ASSIGN(_standardInput, hdl);
}

/**
 * Sets the standard output stream for the task.<br />
 * This is normally a writable NSFileHandle object.
 * If this is an NSPipe, the write end of the pipe is
 * automatically closed on launching.<br />
 * The default behavior is to inherit the parent processes
 * stdout stream.<br />
 * This method cannot be used after a task is launched ...
 * it raises an NSInvalidArgumentException.
 */
- (void)setStandardOutput:(id)hdl
{
    if (_hasLaunched)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - task has been launched"];
    }
    NSAssert(hdl != nil && ([hdl isKindOfClass:[NSFileHandle class]] ||
                            [hdl isKindOfClass:[NSPipe class]]), NSInvalidArgumentException);
    ASSIGN(_standardOutput, hdl);
}

/**
 * Returns the standard error stream for the task - an NSFileHandle
 * unless an NSPipe was passed to -setStandardError:
 */
- (id)standardError
{
    if (_standardError == nil)
    {
        [self setStandardError:[NSFileHandle fileHandleWithStandardError]];
    }
    return _standardError;
}

/**
 * Returns the standard input stream for the task - an NSFileHandle
 * unless an NSPipe was passed to -setStandardInput:
 */
- (id)standardInput
{
    if (_standardInput == nil)
    {
        [self setStandardInput:[NSFileHandle fileHandleWithStandardInput]];
    }
    return _standardInput;
}

/**
 * Returns the standard output stream for the task - an NSFileHandle
 * unless an NSPipe was passed to -setStandardOutput:
 */
- (id)standardOutput
{
    if (_standardOutput == nil)
    {
        [self setStandardOutput:[NSFileHandle fileHandleWithStandardOutput]];
    }
    return _standardOutput;
}

/**
 * Sends a stop signal to the receiver and any subtasks.<br />
 * If the task has not been launched, raises an
 * NSInvalidArgumentException.<br />
 */
- (BOOL)suspend
{
    if (_hasLaunched == NO)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - task has not yet launched"];
    }
#ifdef  HAVE_KILLPG
    killpg(_taskId, SIGSTOP);
#else
    kill(-_taskId, SIGSTOP);
#endif
    return YES;
}

/**
 * Sends a terminate signal to the receiver and any subtasks.<br />
 * If the task has not been launched, raises an
 * <code>NSInvalidArgumentException</code>.<br />
 * Has no effect on a task that has already terminated.<br />
 * When a task terminates, either due to this method being called,
 * or normal termination, an <code>NSTaskDidTerminateNotification</code> is
 * posted.
 */
- (void)terminate
{
    if (_hasLaunched == NO)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - task has not yet launched"];
    }
    if (_hasTerminated)
    {
        return;
    }

    _hasTerminated = YES;
#ifdef  HAVE_KILLPG
    killpg(_taskId, SIGTERM);
#else
    kill(-_taskId, SIGTERM);
#endif
}

/**
 * Returns the termination status of the task.<br />
 * If the task has not completed running, raises an
 * NSInvalidArgumentException.
 */
- (int)terminationStatus
{
    if (_hasLaunched == NO)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - task has not yet launched"];
    }
    if (_hasCollected == NO)
    {
        [self _collectChild];
    }
    if (_hasTerminated == NO)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - task has not yet terminated"];
    }
    return _terminationStatus;
}

/**
 * If the system supports it, this method sets the standard
 * input, output, and error streams to a pseudo-terminal so
 * that, when launched, the child task will act as if it was
 * running interactively on a terminal.  The file handles
 * can then be used to communicate with the child.<br />
 * This method cannot be used after a task is launched ...
 * it raises an NSInvalidArgumentException.<br />
 * The standard input, output and error streams cannot be
 * changed after calling this method.<br />
 * The method returns YES on success, NO on failure.
 */
- (BOOL)usePseudoTerminal
{
    return NO;
}

/**
 * Returns a validated launch path or nil.<br />
 * Allows for the GNUstep host/operating system, and library combination
 * subdirectories in a path, appending them as necessary to try to locate
 * the actual binary to be used.<br />
 * Checks that the binary file exists and is executable.<br />
 * Even tries searching the directories in the PATH environment variable
 * to locate a binary if the original launch path set was not absolute.
 */
- (NSString*)validatedLaunchPath
{
    NSFileManager *mgr;
    NSString  *libs;
    NSString  *cpu;
    NSString  *os;
    NSString  *prog;
    NSString  *lpath;
    NSString  *base_path;
    NSString  *arch_path;
    NSString  *full_path;

    if (_launchPath == nil)
    {
        return nil;
    }

    mgr = [NSFileManager defaultManager];
    libs = [NSBundle _library_combo];
    os = [NSBundle _gnustep_target_os];
    cpu = [NSBundle _gnustep_target_cpu];

    /*
     *	Set lpath to the actual path to use for the executable.
     *	First choice - base_path/architecture/library_combo/prog.
     *	Second choice - base_path/architecture/prog.
     *	Third choice - base_path/prog.
     *	Otherwise - try using PATH environment variable if possible.
     */
    prog = [_launchPath lastPathComponent];
    base_path = [_launchPath stringByDeletingLastPathComponent];
    if ([[base_path lastPathComponent] isEqualToString:libs] == YES) {
        base_path = [base_path stringByDeletingLastPathComponent];
    }
    if ([[base_path lastPathComponent] isEqualToString:os] == YES) {
        base_path = [base_path stringByDeletingLastPathComponent];
    }
    if ([[base_path lastPathComponent] isEqualToString:cpu] == YES) {
        base_path = [base_path stringByDeletingLastPathComponent];
    }
    arch_path = [base_path stringByAppendingPathComponent:cpu];
    arch_path = [arch_path stringByAppendingPathComponent:os];
    full_path = [arch_path stringByAppendingPathComponent:libs];

    lpath = [full_path stringByAppendingPathComponent:prog];
    if ([mgr isExecutableFileAtPath:lpath] == NO)
    {
        lpath = [arch_path stringByAppendingPathComponent:prog];
        if ([mgr isExecutableFileAtPath:lpath] == NO)
        {
            lpath = [base_path stringByAppendingPathComponent:prog];
            if ([mgr isExecutableFileAtPath:lpath] == NO)
            {
                /*
                 * Last resort - if the launch path was simply a program name
                 * get NSBundle to try using the PATH environment
                 * variable to find the executable.
                 */
                if ([base_path isEqualToString:@""] == YES)
                {
                    lpath = [NSBundle _absolutePathOfExecutable:prog];
                }
                if (lpath != nil)
                {
                    if ([mgr isExecutableFileAtPath:lpath] == NO)
                    {
                        lpath = nil;
                    }
                }
            }
        }
    }
    if (lpath != nil)
    {
        /*
         * Make sure we have a standardised absolute path to pass to execve()
         */
        if ([lpath isAbsolutePath] == NO)
        {
            NSString  *current = [mgr currentDirectoryPath];

            lpath = [current stringByAppendingPathComponent:lpath];
        }
        lpath = [lpath stringByStandardizingPath];
    }
    return lpath;
}

/**
 * Suspends the current thread until the task terminates, by
 * waiting in NSRunLoop (NSDefaultRunLoopMode) for the task
 * termination.<br />
 * Returns immediately if the task is not running.
 */
- (void)waitUntilExit
{
    NSTimer   *timer = nil;

    while ([self isRunning])
    {
        NSDate    *limit;

        /*
         *	Poll at 0.1 second intervals.
         */
        limit = [[NSDate alloc] initWithTimeIntervalSinceNow:0.1];
        if (timer == nil)
        {
            timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                     target:nil
                     selector:@selector(class)
                     userInfo:nil
                     repeats:YES];
        }
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
         beforeDate:limit];
        RELEASE(limit);
    }
    [timer invalidate];
}
@end

@implementation NSTask (Private)

- (NSString *)_fullLaunchPath
{
    NSString  *val;

    if (_launchPath == nil)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - no launch path set"];
    }
    val = [self validatedLaunchPath];
    if (val == nil)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - launch path (%@) not valid", _launchPath];
    }

    return val;
}

- (void)_collectChild
{
    [self subclassResponsibility:_cmd];
}

- (void)_terminatedChild:(int)status
{
    [tasksLock lock];
    IF_NO_GC([[self retain] autorelease]; )
    NSMapRemove(activeTasks, (void*)(intptr_t)_taskId);
    [tasksLock unlock];
    _terminationStatus = status;
    _hasCollected = YES;
    _hasTerminated = YES;
    if (_hasNotified == NO)
    {
        NSNotification    *n;

        _hasNotified = YES;
        n = [NSNotification notificationWithName:NSTaskDidTerminateNotification
             object:self
             userInfo:nil];

        [[NSNotificationQueue defaultQueue] enqueueNotification:n
         postingStyle:NSPostASAP
         coalesceMask:NSNotificationNoCoalescing
         forModes:nil];
    }
}

@end


@implementation NSConcreteUnixTask

BOOL
GSPrivateCheckTasks()
{
    BOOL found = NO;

    if (hadChildSignal == YES)
    {
        int result;
        int status;

        hadChildSignal = NO;

        do
        {
            NSTask    *t;

            errno = 0;
            result = waitpid(-1, &status, WNOHANG);
            if (result < 0)
            {
#if defined(WAITDEBUG)
                [tasksLock lock];
                t = (NSTask*)NSMapGet(activeTasks, (void*)(intptr_t)result);
                IF_NO_GC([[t retain] autorelease]; )
                [tasksLock unlock];
                if (t != nil)
                {
                    NSLog(@"waitpid result %d, error %@",
                          result, [NSError _last]);
                }
#endif
            }
            else if (result > 0)
            {
                [tasksLock lock];
                t = (NSTask*)NSMapGet(activeTasks, (void*)(intptr_t)result);
                IF_NO_GC([[t retain] autorelease]; )
                [tasksLock unlock];
                if (t != nil)
                {
                    if (WIFEXITED(status))
                    {
#if defined(WAITDEBUG)
                        NSLog(@"waitpid %d, exit status = %d",
                              result, status);
#endif
                        [t _terminatedChild:WEXITSTATUS(status)];
                        found = YES;
                    }
                    else if (WIFSIGNALED(status))
                    {
#if defined(WAITDEBUG)
                        NSLog(@"waitpid %d, termination status = %d",
                              result, status);
#endif
                        [t _terminatedChild:WTERMSIG(status)];
                        found = YES;
                    }
                    else
                    {
                        NSLog(@"Warning ... task %d neither exited nor signalled",
                              result);
                    }
                }
#if defined(WAITDEBUG)
                else
                {
                    NSLog(@"Received signal for unknown child %d", result);
                }
#endif
            }
        }
        while (result > 0);
    }
    return found;
}

- (void)launch
{
    NSMutableArray    *toClose;
    NSString          *lpath;
    int pid;
    const char        *executable;
    const char        *path;
    int idesc;
    int odesc;
    int edesc;
    NSDictionary      *e = [self environment];
    NSArray       *k = [e allKeys];
    NSArray       *a = [self arguments];
    int ec = [e count];
    int ac = [a count];
    const char        *args[ac+2];
    const char        *envl[ec+1];
    id hdl;
    int i;

    if (_hasLaunched)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - task has already been launched"];
    }

    lpath = [self _fullLaunchPath];
    executable = [lpath fileSystemRepresentation];
    args[0] = executable;

    for (i = 0; i < ac; i++)
    {
        args[i+1] = [[[a objectAtIndex:i] description] lossyCString];
    }
    args[ac+1] = 0;

    for (i = 0; i < ec; i++)
    {
        NSString  *s;
        id key = [k objectAtIndex:i];
        id val = [e objectForKey:key];

        if (val)
        {
            s = [NSString stringWithFormat:@"%@=%@", key, val];
        }
        else
        {
            s = [NSString stringWithFormat:@"%@=", key];
        }
        envl[i] = [s lossyCString];
    }
    envl[ec] = 0;

    path = [[self currentDirectoryPath] fileSystemRepresentation];

    toClose = [NSMutableArray arrayWithCapacity:3];
    hdl = [self standardInput];
    if ([hdl isKindOfClass:[NSPipe class]])
    {
        hdl = [(NSPipe*)hdl fileHandleForReading];
        [toClose addObject:hdl];
    }
    idesc = [hdl fileDescriptor];

    hdl = [self standardOutput];
    if ([hdl isKindOfClass:[NSPipe class]])
    {
        hdl = [(NSPipe*)hdl fileHandleForWriting];
        [toClose addObject:hdl];
    }
    odesc = [hdl fileDescriptor];

    hdl = [self standardError];
    if ([hdl isKindOfClass:[NSPipe class]])
    {
        hdl = [(NSPipe*)hdl fileHandleForWriting];
        /*
         * If we have the same pipe twice we don't want to close it twice
         */
        if ([toClose indexOfObjectIdenticalTo:hdl] == NSNotFound)
        {
            [toClose addObject:hdl];
        }
    }
    edesc = [hdl fileDescriptor];

#ifdef __APPLE__
    /* Use fork instead of vfork on Darwin because setsid() fails under
     * Darwin 7 (aka OS X 10.3) and later while the child is in the vfork.
     */
#define vfork fork
#endif
    pid = vfork();
    if (pid < 0)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - failed to create child process"];
    }
    if (pid == 0)
    {
        int i;

        /* Make sure the task gets default signal setup.
         */
        for (i = 0; i < 32; i++)
        {
            signal(i, SIG_DFL);
        }

        /* Make sure task is session leader in it's own process group
         * and with no controlling terminal.
         * This allows us to use killpg() to put the task to sleep etc,
         * and have the signal effect forked children of the subtask.
         */
#if defined(HAVE_SETSID)
        setsid();
#else
#if defined(HAVE_SETPGRP)
#if defined(SETPGRP_VOID)
        setpgrp();
#else
        setpgrp(getpid(), getpid());
#endif
#else
#if defined(HAVE_SETPGID)
        pid = (int)getpid();
        setpgid(pid, pid);
#endif  /* HAVE_SETPGID */
#endif  /* HAVE_SETPGRP */
        /* Detach from controlling terminal.
         */
#if defined(TIOCNOTTY)
        i = open("/dev/tty", O_RDWR);
        if (i >= 0)
        {
            (void)ioctl(i, TIOCNOTTY, 0);
            (void)close(i);
        }
#endif  /* TIOCNOTTY */
#endif  /* HAVE_SETSID */

        if (_usePseudoTerminal == YES)
        {
            int s;

            s = pty_slave(slave_name);
            if (s < 0)
            {
                exit(1);    /* Failed to open slave!	*/
            }

            /* Set up stdin, stdout and stderr by duplicating descriptors as
             * necessary and closing the originals (to ensure we won't have a
             * pipe left with two write descriptors etc).
             */
            if (s != 0)
            {
                dup2(s, 0);
            }
            if (s != 1)
            {
                dup2(s, 1);
            }
            if (s != 2)
            {
                dup2(s, 2);
            }
        }
        else
        {
            /* Set up stdin, stdout and stderr by duplicating descriptors as
             * necessary and closing the originals (to ensure we won't have a
             * pipe left with two write descriptors etc).
             */
            if (idesc != 0)
            {
                dup2(idesc, 0);
            }
            if (odesc != 1)
            {
                dup2(odesc, 1);
            }
            if (edesc != 2)
            {
                dup2(edesc, 2);
            }
        }

        /*
         * Close any extra descriptors.
         */
        for (i = 3; i < NOFILE; i++)
        {
            (void) close(i);
        }

        chdir(path);
        execve(executable, (char**)args, (char**)envl);
        exit(-1);
    }
    else
    {
        _taskId = pid;
        _hasLaunched = YES;
        ASSIGN(_launchPath, lpath); // Actual path used.

        [tasksLock lock];
        NSMapInsert(activeTasks, (void*)(intptr_t)_taskId, (void*)self);
        [tasksLock unlock];

        /*
         *	Close the ends of any pipes used by the child.
         */
        while ([toClose count] > 0)
        {
            hdl = [toClose objectAtIndex:0];
            [hdl closeFile];
            [toClose removeObjectAtIndex:0];
        }
    }
}

- (void)setStandardError:(id)hdl
{
    if (_usePseudoTerminal == YES)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - set error for task on pseudo terminal"];
    }
    [super setStandardError:hdl];
}

- (void)setStandardInput:(id)hdl
{
    if (_usePseudoTerminal == YES)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - set input for task on pseudo terminal"];
    }
    [super setStandardInput:hdl];
}

- (void)setStandardOutput:(id)hdl
{
    if (_usePseudoTerminal == YES)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"NSTask - set output for task on pseudo terminal"];
    }
    [super setStandardOutput:hdl];
}

- (void)_collectChild
{
    GSPrivateCheckTasks();
}

- (BOOL)usePseudoTerminal
{
    int master;
    NSFileHandle  *fh;

    if (_usePseudoTerminal == YES)
    {
        return YES;
    }
    master = pty_master(slave_name, sizeof(slave_name));
    if (master < 0)
    {
        return NO;
    }
    fh = [[NSFileHandle alloc] initWithFileDescriptor:master
          closeOnDealloc:YES];
    [self setStandardInput:fh];
    RELEASE(fh);
    master = dup(master);
    fh = [[NSFileHandle alloc] initWithFileDescriptor:master
          closeOnDealloc:YES];
    [self setStandardOutput:fh];
    RELEASE(fh);
    master = dup(master);
    fh = [[NSFileHandle alloc] initWithFileDescriptor:master
          closeOnDealloc:YES];
    [self setStandardError:fh];
    RELEASE(fh);
    _usePseudoTerminal = YES;
    return YES;
}

@end

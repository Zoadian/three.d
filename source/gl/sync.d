module three.gl.sync;

public import derelict.opengl3.gl3;
import three.gl.util;
import std.experimental.logger;

enum kOneSecondInNanoSeconds = GLuint64(1000000000);

struct GlSyncManager {
private:
	struct LockRange
	{
		size_t startOffset;
		size_t length;
		
		bool overlaps(LockRange rhs) pure const const @safe nothrow {
			return startOffset < (rhs.startOffset + rhs.length) && rhs.startOffset < (startOffset + length);
		}
	}
	
	struct Lock
	{
		LockRange range;
		GLsync sync;
	}
	
	Lock[] locks;

public:
	void construct() pure @safe nothrow @nogc {
	}
	
	void destruct() pure @safe nothrow @nogc {
	}
	
	void waitForLockedRange(size_t lockBeginOffset, size_t lockLength) nothrow { 
		LockRange testRange = LockRange(lockBeginOffset, lockLength);
		Lock[] swapLocks;
		
		foreach(ref lock; locks) {
			if (testRange.overlaps(lock.range)) {
				waitForSync(lock.sync);
				glCheck!glDeleteSync(lock.sync);
			} 
			else {
				swapLocks ~= lock;
			}
		}

		locks = swapLocks;
	}
	
	void lockRange(size_t lockBeginOffset, size_t lockLength) nothrow {
		LockRange newRange = LockRange(lockBeginOffset, lockLength);
		GLsync syncName = glCheck!glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0);
		locks ~= Lock(newRange, syncName);
	}

private:
	void waitForSync(ref GLsync sync) nothrow {
		version(LockBusyWait) {
			GLbitfield waitFlags = 0;
			GLuint64 waitDuration = 0;
			while(true) {
				GLenum waitRet = glCheck!glClientWaitSync(sync, waitFlags, waitDuration);
				if (waitRet == GL_ALREADY_SIGNALED || waitRet == GL_CONDITION_SATISFIED) {
					return;
				}
				
				if (waitRet == GL_WAIT_FAILED) {
					assert(!"Not sure what to do here. Probably raise an exception or something.");
					return;
				}
				
				// After the first time, need to start flushing, and wait for a looong time.
				waitFlags = GL_SYNC_FLUSH_COMMANDS_BIT;
				waitDuration = kOneSecondInNanoSeconds;
			}
		} 
		else {
			glCheck!glWaitSync(sync, 0, GL_TIMEOUT_IGNORED);
		}
	}
}
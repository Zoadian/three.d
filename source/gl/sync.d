module three.gl.sync;

import three.common;


struct GlSyncManager {
	struct LockRange
	{
		size_t startOffset;
		size_t length;
		
		bool overlaps(LockRange rhs) const {
			return startOffset < (rhs.startOffset + rhs.length) && rhs.startOffset < (startOffset + length);
		}
	}
	
	struct Lock
	{
		LockRange range;
		GLsync sync;
	}
	
	Lock[] locks;
	
	void waitForLockedRange(size_t lockBeginOffset, size_t lockLength) { 
		LockRange testRange = LockRange(lockBeginOffset, lockLength);
		Lock[] swapLocks;
		
		foreach(ref lock; locks) {
			if (testRange.overlaps(lock.range)) {
				version(LockBusyWait) {
					GLbitfield waitFlags = 0;
					GLuint64 waitDuration = 0;
					while(true) {
						GLenum waitRet = glCheck!glClientWaitSync(lock.sync, waitFlags, waitDuration);
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
					glCheck!glWaitSync(lock.sync, 0, GL_TIMEOUT_IGNORED);
				}
				
				glCheck!glDeleteSync(lock.sync);
			} 
			else {
				swapLocks ~= lock;
			}
		}
		
		import std.algorithm : swap;
		swap(locks, swapLocks);
	}
	
	void lockRange(size_t lockBeginOffset, size_t lockLength) {
		LockRange newRange = LockRange(lockBeginOffset, lockLength);
		GLsync syncName = glCheck!glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0);
		locks ~= Lock(newRange, syncName);
	}
}
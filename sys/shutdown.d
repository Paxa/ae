/**
 * Application shutdown control (with SIGTERM handling).
 * Different from atexit in that it controls initiation
 * of graceful shutdown, as opposed to cleanup actions
 * that are done as part of the shutdown process.
 *
 * Note: thread safety of this module is questionable.
 *
 * License:
 *   This Source Code Form is subject to the terms of
 *   the Mozilla Public License, v. 2.0. If a copy of
 *   the MPL was not distributed with this file, You
 *   can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Authors:
 *   Vladimir Panteleev <vladimir@thecybershadow.net>
 */

module ae.sys.shutdown;

void addShutdownHandler(void delegate() fn)
{
	if (handlers.length == 0)
		register();
	handlers ~= fn;
}

/// Calls all registered handlers.
void shutdown()
{
	foreach (fn; handlers)
		fn();
}

private:

void register()
{
	version(Posix)
	{
		import ae.sys.signals;
		addSignalHandler(SIGTERM, { shutdown(); });
	}
	else
	version(Windows)
	{
		import core.sys.windows.windows;

		static shared bool closing = false;

		extern(Windows)
		static BOOL handlerRoutine(DWORD dwCtrlType)
		{
			if (!closing)
			{
				closing = true;
				auto msg = "Shutdown event received, shutting down.\r\n";
				DWORD written;
				WriteConsoleA(GetStdHandle(STD_OUTPUT_HANDLE), msg.ptr, msg.length, &written, null);
				shutdown();
				return TRUE;
			}
			return FALSE;
		}

		SetConsoleCtrlHandler(&handlerRoutine, TRUE);
	}
}

shared void delegate()[] handlers;

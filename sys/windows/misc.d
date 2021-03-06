/**
 * Miscellaneous Windows utility code.
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

module ae.sys.windows.misc;

import std.string;

import win32.winbase;
import win32.wincon;
import win32.winnt;
import win32.winuser;

import ae.sys.windows.exception;
import ae.sys.windows.text;

LARGE_INTEGER largeInteger(long n)
{
	LARGE_INTEGER li; li.QuadPart = n; return li;
}

ULARGE_INTEGER ulargeInteger(ulong n)
{
	ULARGE_INTEGER li; li.QuadPart = n; return li;
}

ulong makeUlong(DWORD dwLow, DWORD dwHigh)
{
	ULARGE_INTEGER li;
	li.LowPart  = dwLow;
	li.HighPart = dwHigh;
	return li.QuadPart;
}

// ***************************************************************************

// Messages

void processWindowsMessages()
{
	MSG m;
	while (PeekMessageW(&m, null, 0, 0, PM_REMOVE))
	{
		TranslateMessage(&m);
		DispatchMessageW(&m);
	}
}

void messageLoop()
{
	MSG m;
	while (GetMessageW(&m, null, 0, 0))
	{
		TranslateMessage(&m);
		DispatchMessageW(&m);
	}
}

// ***************************************************************************

int messageBox(string message, string title, int style=0)
{
	return MessageBoxW(null, toWStringz(message), toWStringz(title), style);
}

uint getLastInputInfo()
{
	LASTINPUTINFO lii = { LASTINPUTINFO.sizeof };
	wenforce(GetLastInputInfo(&lii), "GetLastInputInfo");
	return lii.dwTime;
}

// ***************************************************************************

/// Hides the console window, but only if we are the owner.
void hideOwnConsoleWindow()
{
	HWND w = GetConsoleWindow();
	if (!w)
		return;
	DWORD pid;
	GetWindowThreadProcessId(w, &pid);
	if (pid == GetCurrentProcessId())
		ShowWindow(w, SW_HIDE);
}

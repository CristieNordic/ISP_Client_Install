# Client Install
To get this working we need to do following steps.
Make sure you run in **Administrator Mode** when you start PowerShell.
You must download the IBM Spectrum Protect Backup-Archive Client version 8.1.0.2 or newer and extract the data.
The **.\TSMClient** directory most be in the same directory where you have the **ispinstall.ps1** script.

It is recommended that you modify the *ba_dsm.opt* file to fit your environment, and this is a early version of the script many function do you probably need to disable in the code to be able to get it working.

If you want to change the default values please open the install.ps1 file and go to line 13-15 and modify the default values.

# Install Backup-Archive Client
Only the basic are working at the moment. Please test the script and see if it is good enough for you.

# Install SQL Client
Not working yet

# Install Exchange Client
Not working yet

# Requests
If you find any bugs or want me to priorities any functionality please great a GitHub ticket.

# Wanna help?
If you want to help, please create a fork and commit when you are done.

# OEM or Resale?
You are allowed to include this part of your solution, but remember it's goes under the MIT license.
That mean basically you are not allowed to invoice your customer for this script.


# MIT License

Copyright (c) [2017] [Cristie Nordic AB]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

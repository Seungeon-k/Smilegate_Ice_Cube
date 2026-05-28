using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using Microsoft.Win32;

namespace GameFramework.Editor.LuaEditorMenu
{
    public static class FileAssociationHelper
    {
        /// <summary>
        /// CAUTION: Windows 플랫폼만 지원함!
        /// </summary>
        public static bool HasAssociationForExtension(string extension)
        {
            if (!extension.StartsWith("."))
                extension = "." + extension;

            // 1. .code-workspace → ProgID 조회
            using (var extKey = Registry.ClassesRoot.OpenSubKey(extension))
            {
                if (extKey == null)
                    return false;

                var progId = extKey.GetValue(null) as string;
                if (string.IsNullOrWhiteSpace(progId))
                    return false;

                // 2. ProgID\shell\open\command 조회
                using (var cmdKey = Registry.ClassesRoot.OpenSubKey(progId + @"\shell\open\command"))
                {
                    var command = cmdKey?.GetValue(null) as string;
                    return !string.IsNullOrWhiteSpace(command);
                }
            }
        }
    }
}
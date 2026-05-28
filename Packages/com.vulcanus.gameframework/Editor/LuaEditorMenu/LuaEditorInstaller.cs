using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;

namespace GameFramework.Editor.LuaEditorMenu
{
    public static class LuaEditorInstaller
    {
        // 설치할 VS Code 확장 목록
        private const string LuaExtension = "tangzx.emmylua";

        // VS Code User 설치(관리자 권한 불필요). x64 기준.
        // 공식 다운로드 페이지의 안정 리다이렉트를 사용합니다.
        private const string VscodeUserSetupUrl =
            "https://update.code.visualstudio.com/latest/win32-x64-user/stable";
        // 대안(동일 목적의 안정 리다이렉트):
        // "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user";

        private static string _vsCodeCliPath;

        public static void Clear()
        {
            _vsCodeCliPath = null;
        }

        /// <summary>
        /// VSCode가 설치되어 있는가?
        /// </summary>
        public static bool IsEditorInstalled()
        {
            if (string.IsNullOrEmpty(_vsCodeCliPath))
                _vsCodeCliPath = FindVSCode();
            return !string.IsNullOrEmpty(_vsCodeCliPath);
        }

        /// <summary>
        /// Lua extension이 설치되었는가?
        /// </summary>
        /// <returns></returns>
        public static bool IsLuaExtensionInstalled()
        {
            if (!IsEditorInstalled())
                return false;

            var extensions = ListInstalledExtensions();
            return extensions.Contains(LuaExtension);
        }

        public static (bool installed, string message) InstallEditor()
        {
            try
            {
                var tempDir = Path.Combine(Path.GetTempPath(), "vscode_setup");
                Directory.CreateDirectory(tempDir);
                var installerPath = Path.Combine(tempDir, "VSCodeUserSetup-x64.exe");

                using (var wc = new WebClient())
                {
                    wc.DownloadFile(VscodeUserSetupUrl, installerPath);
                }

                // Inno Setup 무인 설치 스위치
                // - addtopath / addcontextmenu / file association 등 필요한 작업만 선택
                var args = new StringBuilder();
                args.Append("/VERYSILENT ");
                args.Append("/NORESTART ");
                // 설치 직후 자동 실행 방지
                args.Append("/MERGETASKS=!runcode,addtopath,addcontextmenufiles,addcontextmenufolders ");

                var (exit, _, se) = RunCommand(installerPath, args.ToString(), TimeSpan.FromMinutes(10));
                if (exit != 0)
                {
                    return (false, $"Installer exit={exit}\n{se}");
                }

                return (true, "VS Code installed!");
            }
            catch (Exception ex)
            {
                return (false, ex.ToString());
            }
        }

        public static bool InstallLuaExtension()
        {
            (int code, string so, string se) =
                RunCommand(_vsCodeCliPath, $"--install-extension \"{LuaExtension}\" --force", TimeSpan.FromMinutes(2));
            LogProcess($"[code --install-extension {LuaExtension}]", code, so, se);
            return code == 0;
        }

        public static void OpenProject(string projectPath)
        {
            (int code, string so, string se) = RunCodeCli(projectPath, TimeSpan.Zero);
            LogProcess($"[code {projectPath}]", code, so, se);
        }

        private static string FindVSCode()
        {
            // 우선 PATH에 있는지 체크
            if (IsCommandAvailable("code", "--version"))
            {
                return "code"; // PATH에 있음
            }

            // 대표적인 사용자 설치 경로 (CLI는 code.cmd)
            // 예) %LocalAppData%\Programs\Microsoft VS Code\bin\code.cmd
            var candidates = new[]
            {
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                    @"Programs\Microsoft VS Code\bin\code.cmd"),
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles),
                    @"Microsoft VS Code\bin\code.cmd"),
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86),
                    @"Microsoft VS Code\bin\code.cmd"),
            };

            foreach (var cliPath in candidates)
            {
                if (File.Exists(cliPath))
                {
                    return cliPath;
                }
            }

            return "";
        }

        private static List<string> ListInstalledExtensions()
        {
            var (exit, so, se) = RunCodeCli("--list-extensions", TimeSpan.FromMinutes(1));
            LogProcess("[code --list-extensions]", exit, so, se);

            if (exit != 0) return new List<string>();
            var lines = so.Split(new[] { "\r\n", "\n" }, StringSplitOptions.RemoveEmptyEntries);
            return lines.Select(l => l.Trim()).Where(l => !string.IsNullOrWhiteSpace(l)).ToList();
        }

        private static bool IsCommandAvailable(string fileName, string versionArg)
        {
            try
            {
                var (exit, _, _) = RunCommand(fileName, versionArg, TimeSpan.FromSeconds(5));
                return exit == 0;
            }
            catch
            {
                return false;
            }
        }

        private static (int exitCode, string stdout, string stderr) RunCodeCli(string args, TimeSpan timeout)
        {
            // code가 PATH에만 있고 문자열 "code"인 경우도 지원
            if (string.Equals(_vsCodeCliPath, "code", StringComparison.OrdinalIgnoreCase))
            {
                return RunCommand("cmd.exe", "/c code " + args, timeout);
            }
            else
            {
                return RunCommand(_vsCodeCliPath, args, timeout);
            }
        }

        private static (int exitCode, string stdout, string stderr) RunCommand(string fileName, string args,
            TimeSpan timeout)
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = fileName,
                Arguments = args,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true,
                StandardOutputEncoding = Encoding.UTF8,
                StandardErrorEncoding = Encoding.UTF8,
            };

            using (var proc = new Process())
            {
                proc.StartInfo = startInfo;
                var so = new StringBuilder();
                var se = new StringBuilder();

                proc.OutputDataReceived += (_, e) =>
                {
                    if (e.Data != null) so.AppendLine(e.Data);
                };
                proc.ErrorDataReceived += (_, e) =>
                {
                    if (e.Data != null) se.AppendLine(e.Data);
                };

                proc.Start();
                proc.BeginOutputReadLine();
                proc.BeginErrorReadLine();

                if (timeout <= TimeSpan.Zero)
                {
                    return (0, "", "");
                }

                if (!proc.WaitForExit((int) timeout.TotalMilliseconds))
                {
                    try
                    {
                        proc.Kill();
                    }
                    catch
                    {
                        /* ignore */
                    }

                    throw new TimeoutException($"Timed out to run {fileName} {args}");
                }
                return (proc.ExitCode, so.ToString(), se.ToString());

            }
        }

        private static void LogProcess(string tag, int exitCode, string stdout, string stderr)
        {
            // TODO(bsookim): 개발환경에서만 노출되게 개선이 필요함
            if (!string.IsNullOrWhiteSpace(stdout))
                UnityEngine.Debug.Log($"{tag} stdout:\n{stdout}");
            if (!string.IsNullOrWhiteSpace(stderr))
                UnityEngine.Debug.LogWarning($"{tag} stderr:\n{stderr}");

            if (exitCode != 0)
                UnityEngine.Debug.LogWarning($"{tag} exit-code: {exitCode}");
        }
    }
}
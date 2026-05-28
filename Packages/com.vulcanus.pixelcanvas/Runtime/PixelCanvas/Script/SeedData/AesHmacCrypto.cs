using System.IO;
using System;
using UnityEngine;
using System.Security.Cryptography;
using System.Text;

namespace PixelCanvas
{
    public static class AesHmacCrypto
    {
        private readonly static string keyPath = Path.Combine(Path.Combine(Application.streamingAssetsPath, "AES_Crypto"), "aesKey.dat");
        private static byte[] _key;

        private const int KeySize = 32;  // AES Key (32 bytes)
        private const int IvSize = 16;	 // AES IV (16 bytes)
        private const int HmacSize = 32; // HMAC-SHA256 (32 bytes)

        private static byte[] GetAesKey()
        {

            if (_key == null)
            {
                _key = GenerateKey("whrudqo dlrhtdp whrwjrdmf skarlek");

                //if (File.Exists(keyPath))
                //{
                //    _key = File.ReadAllBytes(keyPath);
                //}
                //else
                //{
                //    _key = GenerateRandomBytes(KeySize); // 256-bit key
                //    File.WriteAllBytes(keyPath, _key);
                //}
            }

            //Encoding.UTF8.GetString(_key);
            //Debug.LogError(Encoding.UTF8.GetString(_key));
            return _key;
        }

        private static byte[] GenerateRandomBytes(int length)
        {
            var randomBytes = new byte[length];

            // RNGCryptoServiceProvider : Random Generater
            using (RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider())
            {
                rng.GetBytes(randomBytes);
            }
            return randomBytes;
        }

        private static byte[] GenerateKey(string key)
        {
            using (var sha256 = SHA256.Create())
            {
                var keyBytes = Encoding.UTF8.GetBytes(key);
                var hash = sha256.ComputeHash(keyBytes);
                var trimmedKey = new byte[KeySize]; // 256 bit key
                Array.Copy(hash, trimmedKey, KeySize);
                return trimmedKey;
            }
        }

        private static byte[] ComputeHmac(byte[] data, byte[] key)
        {
            using (var hmac = new HMACSHA256(key))
            {
                return hmac.ComputeHash(data);
            }
        }

        private static bool EqualTo(byte[] a, byte[] b)
        {
            if (a.Length != b.Length) return false;

            for (int i = 0; i < a.Length; i++)
            {
                if (a[i] != b[i]) return false;
            }
            return true;
        }

        public static byte[] Encrypt(byte[] bytes)
        {
            var key = GetAesKey();
            var iv = new byte[IvSize];
            RandomNumberGenerator.Create().GetBytes(iv);

            var cipherData = default(byte[]);
            using (var aes = Aes.Create())
            {
                aes.Key = key;
                aes.IV = iv;
                aes.Mode = CipherMode.CBC;
                aes.Padding = PaddingMode.PKCS7;

                using (var ms = new MemoryStream())
                {
                    using (var cs = new CryptoStream(ms, aes.CreateEncryptor(), CryptoStreamMode.Write))
                    {
                        cs.Write(bytes, 0, bytes.Length);
                    }
                    cipherData = ms.ToArray();
                }
            }

            var vi_cipher = new byte[IvSize + cipherData.Length];
            Buffer.BlockCopy(iv, 0, vi_cipher, 0, IvSize);
            Buffer.BlockCopy(cipherData, 0, vi_cipher, IvSize, cipherData.Length);

            var hmac = ComputeHmac(vi_cipher, key);

            // [Hmac | IV | CipherText] -> bytes
            var result = new byte[HmacSize + vi_cipher.Length];
            Buffer.BlockCopy(hmac, 0, result, 0, HmacSize);
            Buffer.BlockCopy(vi_cipher, 0, result, HmacSize, vi_cipher.Length);
            return result;
        }

        public static EPixelCanvas_Result TryDecrypt(byte[] bytes, out byte[] decrypedBytes)
        {
            decrypedBytes = null;

            var key = GetAesKey();

            // bytes -> [Hmac | IV | CipherText]
            var hmac = new byte[HmacSize];
            var vi_cipher = new byte[bytes.Length - HmacSize];
            var iv = new byte[IvSize];
            var cipherData = new byte[bytes.Length - IvSize - HmacSize];

            Buffer.BlockCopy(bytes, 0, hmac, 0, HmacSize);
            Buffer.BlockCopy(bytes, HmacSize, vi_cipher, 0, vi_cipher.Length);

            // HMAC Check
            var computedHmac = ComputeHmac(vi_cipher, key);
            if (EqualTo(hmac, computedHmac) == false)
                return EPixelCanvas_Result.Error_HmacValidation;

            Buffer.BlockCopy(vi_cipher, 0, iv, 0, IvSize);
            Buffer.BlockCopy(vi_cipher, IvSize, cipherData, 0, cipherData.Length);

            using (var aes = Aes.Create())
            {
                aes.Key = key;
                aes.IV = iv;
                aes.Mode = CipherMode.CBC;
                aes.Padding = PaddingMode.PKCS7;

                using (var ms = new MemoryStream())
                {
                    using (var cs = new CryptoStream(ms, aes.CreateDecryptor(), CryptoStreamMode.Write))
                    {
                        cs.Write(cipherData, 0, cipherData.Length);
                    }
                    decrypedBytes = ms.ToArray();
                    return EPixelCanvas_Result.Success;
                }
            }
        }
    }
}
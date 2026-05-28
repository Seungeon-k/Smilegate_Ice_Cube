# USGWebServices.Editor.ResourceStore.Api.ResourceStoreApi

All URIs are relative to */v1*

| Method | HTTP request | Description |
|--------|--------------|-------------|
| [**CreateWebview**](ResourceStoreApi.md#createwebview) | **POST** /resource-store/webview | Create a new Webview App |
| [**DestroyWebview**](ResourceStoreApi.md#destroywebview) | **DELETE** /resource-store/webview | Destroy the Webview App |
| [**GetAccessToken**](ResourceStoreApi.md#getaccesstoken) | **GET** /resource-store/access-token | Get User Access Token |
| [**GetUserInfo**](ResourceStoreApi.md#getuserinfo) | **GET** /resource-store/get-user-info | Get User Information |
| [**GetVulcanusAppConfiguration**](ResourceStoreApi.md#getvulcanusappconfiguration) | **GET** /resource-store/get-vulcanus-app-config | Get VulcanusAppConfiguration |
| [**InvalidateAccessToken**](ResourceStoreApi.md#invalidateaccesstoken) | **DELETE** /resource-store/access-token | Invalidate the User Access Token |
| [**OpenExternalBrowser**](ResourceStoreApi.md#openexternalbrowser) | **GET** /resource-store/open-external-browser | Open URL in an default web browser(by Stove) |
| [**OpenWebviewUrl**](ResourceStoreApi.md#openwebviewurl) | **GET** /resource-store/webview | open a resource URL in the Webview App |
| [**Publish**](ResourceStoreApi.md#publish) | **POST** /resource-store/publish | Publish an item to Resource Store |
| [**RecreateWebview**](ResourceStoreApi.md#recreatewebview) | **PUT** /resource-store/webview | Recreate the Webview App |
| [**RestartUnityProject**](ResourceStoreApi.md#restartunityproject) | **GET** /resource-store/restart-unity-project | Restart Unity Project |
| [**SelectAction**](ResourceStoreApi.md#selectaction) | **POST** /resource-store/select-action | Select an action to publish |
| [**SendProjectHeartbeat**](ResourceStoreApi.md#sendprojectheartbeat) | **POST** /resource-store/heartbeat | Send project heartbeat |

<a id="createwebview"></a>
# **CreateWebview**
> string CreateWebview (int pid)

Create a new Webview App

### Example
```csharp
using System.Collections.Generic;
using System.Diagnostics;
using USGWebServices.Editor.ResourceStore.Api;
using USGWebServices.Editor.ResourceStore.Client;
using USGWebServices.Editor.ResourceStore.Model;

namespace Example
{
    public class CreateWebviewExample
    {
        public static void Main()
        {
            Configuration config = new Configuration();
            config.BasePath = "/v1";
            var apiInstance = new ResourceStoreApi(config);
            var pid = 1234;  // int | 

            try
            {
                // Create a new Webview App
                string result = apiInstance.CreateWebview(pid);
                Debug.WriteLine(result);
            }
            catch (ApiException  e)
            {
                Debug.Print("Exception when calling ResourceStoreApi.CreateWebview: " + e.Message);
                Debug.Print("Status Code: " + e.ErrorCode);
                Debug.Print(e.StackTrace);
            }
        }
    }
}
```

#### Using the CreateWebviewWithHttpInfo variant
This returns an ApiResponse object which contains the response data, status code and headers.

```csharp
try
{
    // Create a new Webview App
    ApiResponse<string> response = apiInstance.CreateWebviewWithHttpInfo(pid);
    Debug.Write("Status Code: " + response.StatusCode);
    Debug.Write("Response Headers: " + response.Headers);
    Debug.Write("Response Body: " + response.Data);
}
catch (ApiException e)
{
    Debug.Print("Exception when calling ResourceStoreApi.CreateWebviewWithHttpInfo: " + e.Message);
    Debug.Print("Status Code: " + e.ErrorCode);
    Debug.Print(e.StackTrace);
}
```

### Parameters

| Name | Type | Description | Notes |
|------|------|-------------|-------|
| **pid** | **int** |  |  |

### Return type

**string**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | Accepted |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

<a id="destroywebview"></a>
# **DestroyWebview**
> void DestroyWebview (int pid, bool publishOnly)

Destroy the Webview App

### Example
```csharp
using System.Collections.Generic;
using System.Diagnostics;
using USGWebServices.Editor.ResourceStore.Api;
using USGWebServices.Editor.ResourceStore.Client;
using USGWebServices.Editor.ResourceStore.Model;

namespace Example
{
    public class DestroyWebviewExample
    {
        public static void Main()
        {
            Configuration config = new Configuration();
            config.BasePath = "/v1";
            var apiInstance = new ResourceStoreApi(config);
            var pid = 1234;  // int | 
            var publishOnly = true;  // bool | 

            try
            {
                // Destroy the Webview App
                apiInstance.DestroyWebview(pid, publishOnly);
            }
            catch (ApiException  e)
            {
                Debug.Print("Exception when calling ResourceStoreApi.DestroyWebview: " + e.Message);
                Debug.Print("Status Code: " + e.ErrorCode);
                Debug.Print(e.StackTrace);
            }
        }
    }
}
```

#### Using the DestroyWebviewWithHttpInfo variant
This returns an ApiResponse object which contains the response data, status code and headers.

```csharp
try
{
    // Destroy the Webview App
    apiInstance.DestroyWebviewWithHttpInfo(pid, publishOnly);
}
catch (ApiException e)
{
    Debug.Print("Exception when calling ResourceStoreApi.DestroyWebviewWithHttpInfo: " + e.Message);
    Debug.Print("Status Code: " + e.ErrorCode);
    Debug.Print(e.StackTrace);
}
```

### Parameters

| Name | Type | Description | Notes |
|------|------|-------------|-------|
| **pid** | **int** |  |  |
| **publishOnly** | **bool** |  |  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | Accepted |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

<a id="getaccesstoken"></a>
# **GetAccessToken**
> AccessToken GetAccessToken ()

Get User Access Token

This is the GetAccessToken operation originated from UGCAS

### Example
```csharp
using System.Collections.Generic;
using System.Diagnostics;
using USGWebServices.Editor.ResourceStore.Api;
using USGWebServices.Editor.ResourceStore.Client;
using USGWebServices.Editor.ResourceStore.Model;

namespace Example
{
    public class GetAccessTokenExample
    {
        public static void Main()
        {
            Configuration config = new Configuration();
            config.BasePath = "/v1";
            var apiInstance = new ResourceStoreApi(config);

            try
            {
                // Get User Access Token
                AccessToken result = apiInstance.GetAccessToken();
                Debug.WriteLine(result);
            }
            catch (ApiException  e)
            {
                Debug.Print("Exception when calling ResourceStoreApi.GetAccessToken: " + e.Message);
                Debug.Print("Status Code: " + e.ErrorCode);
                Debug.Print(e.StackTrace);
            }
        }
    }
}
```

#### Using the GetAccessTokenWithHttpInfo variant
This returns an ApiResponse object which contains the response data, status code and headers.

```csharp
try
{
    // Get User Access Token
    ApiResponse<AccessToken> response = apiInstance.GetAccessTokenWithHttpInfo();
    Debug.Write("Status Code: " + response.StatusCode);
    Debug.Write("Response Headers: " + response.Headers);
    Debug.Write("Response Body: " + response.Data);
}
catch (ApiException e)
{
    Debug.Print("Exception when calling ResourceStoreApi.GetAccessTokenWithHttpInfo: " + e.Message);
    Debug.Print("Status Code: " + e.ErrorCode);
    Debug.Print(e.StackTrace);
}
```

### Parameters
This endpoint does not need any parameter.
### Return type

[**AccessToken**](AccessToken.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | OK |  -  |
| **401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

<a id="getuserinfo"></a>
# **GetUserInfo**
> UserInfo GetUserInfo ()

Get User Information

This is the GetUserInfo operation

### Example
```csharp
using System.Collections.Generic;
using System.Diagnostics;
using USGWebServices.Editor.ResourceStore.Api;
using USGWebServices.Editor.ResourceStore.Client;
using USGWebServices.Editor.ResourceStore.Model;

namespace Example
{
    public class GetUserInfoExample
    {
        public static void Main()
        {
            Configuration config = new Configuration();
            config.BasePath = "/v1";
            var apiInstance = new ResourceStoreApi(config);

            try
            {
                // Get User Information
                UserInfo result = apiInstance.GetUserInfo();
                Debug.WriteLine(result);
            }
            catch (ApiException  e)
            {
                Debug.Print("Exception when calling ResourceStoreApi.GetUserInfo: " + e.Message);
                Debug.Print("Status Code: " + e.ErrorCode);
                Debug.Print(e.StackTrace);
            }
        }
    }
}
```

#### Using the GetUserInfoWithHttpInfo variant
This returns an ApiResponse object which contains the response data, status code and headers.

```csharp
try
{
    // Get User Information
    ApiResponse<UserInfo> response = apiInstance.GetUserInfoWithHttpInfo();
    Debug.Write("Status Code: " + response.StatusCode);
    Debug.Write("Response Headers: " + response.Headers);
    Debug.Write("Response Body: " + response.Data);
}
catch (ApiException e)
{
    Debug.Print("Exception when calling ResourceStoreApi.GetUserInfoWithHttpInfo: " + e.Message);
    Debug.Print("Status Code: " + e.ErrorCode);
    Debug.Print(e.StackTrace);
}
```

### Parameters
This endpoint does not need any parameter.
### Return type

[**UserInfo**](UserInfo.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | OK |  -  |
| **404** | Not Found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

<a id="getvulcanusappconfiguration"></a>
# **GetVulcanusAppConfiguration**
> VulcanusAppConfiguration GetVulcanusAppConfiguration ()

Get VulcanusAppConfiguration

Get VulcanusAppConfiguration

### Example
```csharp
using System.Collections.Generic;
using System.Diagnostics;
using USGWebServices.Editor.ResourceStore.Api;
using USGWebServices.Editor.ResourceStore.Client;
using USGWebServices.Editor.ResourceStore.Model;

namespace Example
{
    public class GetVulcanusAppConfigurationExample
    {
        public static void Main()
        {
            Configuration config = new Configuration();
            config.BasePath = "/v1";
            var apiInstance = new ResourceStoreApi(config);

            try
            {
                // Get VulcanusAppConfiguration
                VulcanusAppConfiguration result = apiInstance.GetVulcanusAppConfiguration();
                Debug.WriteLine(result);
            }
            catch (ApiException  e)
            {
                Debug.Print("Exception when calling ResourceStoreApi.GetVulcanusAppConfiguration: " + e.Message);
                Debug.Print("Status Code: " + e.ErrorCode);
                Debug.Print(e.StackTrace);
            }
        }
    }
}
```

#### Using the GetVulcanusAppConfigurationWithHttpInfo variant
This returns an ApiResponse object which contains the response data, status code and headers.

```csharp
try
{
    // Get VulcanusAppConfiguration
    ApiResponse<VulcanusAppConfiguration> response = apiInstance.GetVulcanusAppConfigurationWithHttpInfo();
    Debug.Write("Status Code: " + response.StatusCode);
    Debug.Write("Response Headers: " + response.Headers);
    Debug.Write("Response Body: " + response.Data);
}
catch (ApiException e)
{
    Debug.Print("Exception when calling ResourceStoreApi.GetVulcanusAppConfigurationWithHttpInfo: " + e.Message);
    Debug.Print("Status Code: " + e.ErrorCode);
    Debug.Print(e.StackTrace);
}
```

### Parameters
This endpoint does not need any parameter.
### Return type

[**VulcanusAppConfiguration**](VulcanusAppConfiguration.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | OK |  -  |
| **401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

<a id="invalidateaccesstoken"></a>
# **InvalidateAccessToken**
> void InvalidateAccessToken ()

Invalidate the User Access Token

### Example
```csharp
using System.Collections.Generic;
using System.Diagnostics;
using USGWebServices.Editor.ResourceStore.Api;
using USGWebServices.Editor.ResourceStore.Client;
using USGWebServices.Editor.ResourceStore.Model;

namespace Example
{
    public class InvalidateAccessTokenExample
    {
        public static void Main()
        {
            Configuration config = new Configuration();
            config.BasePath = "/v1";
            var apiInstance = new ResourceStoreApi(config);

            try
            {
                // Invalidate the User Access Token
                apiInstance.InvalidateAccessToken();
            }
            catch (ApiException  e)
            {
                Debug.Print("Exception when calling ResourceStoreApi.InvalidateAccessToken: " + e.Message);
                Debug.Print("Status Code: " + e.ErrorCode);
                Debug.Print(e.StackTrace);
            }
        }
    }
}
```

#### Using the InvalidateAccessTokenWithHttpInfo variant
This returns an ApiResponse object which contains the response data, status code and headers.

```csharp
try
{
    // Invalidate the User Access Token
    apiInstance.InvalidateAccessTokenWithHttpInfo();
}
catch (ApiException e)
{
    Debug.Print("Exception when calling ResourceStoreApi.InvalidateAccessTokenWithHttpInfo: " + e.Message);
    Debug.Print("Status Code: " + e.ErrorCode);
    Debug.Print(e.StackTrace);
}
```

### Parameters
This endpoint does not need any parameter.
### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

<a id="openexternalbrowser"></a>
# **OpenExternalBrowser**
> void OpenExternalBrowser (string url)

Open URL in an default web browser(by Stove)

### Example
```csharp
using System.Collections.Generic;
using System.Diagnostics;
using USGWebServices.Editor.ResourceStore.Api;
using USGWebServices.Editor.ResourceStore.Client;
using USGWebServices.Editor.ResourceStore.Model;

namespace Example
{
    public class OpenExternalBrowserExample
    {
        public static void Main()
        {
            Configuration config = new Configuration();
            config.BasePath = "/v1";
            var apiInstance = new ResourceStoreApi(config);
            var url = http://something;  // string | 

            try
            {
                // Open URL in an default web browser(by Stove)
                apiInstance.OpenExternalBrowser(url);
            }
            catch (ApiException  e)
            {
                Debug.Print("Exception when calling ResourceStoreApi.OpenExternalBrowser: " + e.Message);
                Debug.Print("Status Code: " + e.ErrorCode);
                Debug.Print(e.StackTrace);
            }
        }
    }
}
```

#### Using the OpenExternalBrowserWithHttpInfo variant
This returns an ApiResponse object which contains the response data, status code and headers.

```csharp
try
{
    // Open URL in an default web browser(by Stove)
    apiInstance.OpenExternalBrowserWithHttpInfo(url);
}
catch (ApiException e)
{
    Debug.Print("Exception when calling ResourceStoreApi.OpenExternalBrowserWithHttpInfo: " + e.Message);
    Debug.Print("Status Code: " + e.ErrorCode);
    Debug.Print(e.StackTrace);
}
```

### Parameters

| Name | Type | Description | Notes |
|------|------|-------------|-------|
| **url** | **string** |  |  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | OK |  -  |
| **400** | Bad Request |  -  |
| **401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

<a id="openwebviewurl"></a>
# **OpenWebviewUrl**
> void OpenWebviewUrl (string url, int pid, bool publishOnly)

open a resource URL in the Webview App

### Example
```csharp
using System.Collections.Generic;
using System.Diagnostics;
using USGWebServices.Editor.ResourceStore.Api;
using USGWebServices.Editor.ResourceStore.Client;
using USGWebServices.Editor.ResourceStore.Model;

namespace Example
{
    public class OpenWebviewUrlExample
    {
        public static void Main()
        {
            Configuration config = new Configuration();
            config.BasePath = "/v1";
            var apiInstance = new ResourceStoreApi(config);
            var url = https://example.com/;  // string | 
            var pid = 1234;  // int | 
            var publishOnly = true;  // bool | 

            try
            {
                // open a resource URL in the Webview App
                apiInstance.OpenWebviewUrl(url, pid, publishOnly);
            }
            catch (ApiException  e)
            {
                Debug.Print("Exception when calling ResourceStoreApi.OpenWebviewUrl: " + e.Message);
                Debug.Print("Status Code: " + e.ErrorCode);
                Debug.Print(e.StackTrace);
            }
        }
    }
}
```

#### Using the OpenWebviewUrlWithHttpInfo variant
This returns an ApiResponse object which contains the response data, status code and headers.

```csharp
try
{
    // open a resource URL in the Webview App
    apiInstance.OpenWebviewUrlWithHttpInfo(url, pid, publishOnly);
}
catch (ApiException e)
{
    Debug.Print("Exception when calling ResourceStoreApi.OpenWebviewUrlWithHttpInfo: " + e.Message);
    Debug.Print("Status Code: " + e.ErrorCode);
    Debug.Print(e.StackTrace);
}
```

### Parameters

| Name | Type | Description | Notes |
|------|------|-------------|-------|
| **url** | **string** |  |  |
| **pid** | **int** |  |  |
| **publishOnly** | **bool** |  |  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | Ok |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

<a id="publish"></a>
# **Publish**
> SelectAction Publish (string url, int pid, string stoveData, int? minWidth = null, int? minHeight = null, int? width = null, int? height = null)

Publish an item to Resource Store

### Example
```csharp
using System.Collections.Generic;
using System.Diagnostics;
using USGWebServices.Editor.ResourceStore.Api;
using USGWebServices.Editor.ResourceStore.Client;
using USGWebServices.Editor.ResourceStore.Model;

namespace Example
{
    public class PublishExample
    {
        public static void Main()
        {
            Configuration config = new Configuration();
            config.BasePath = "/v1";
            var apiInstance = new ResourceStoreApi(config);
            var url = https://example.com/;  // string | 
            var pid = 1234;  // int | 
            var stoveData = {'json':'string'};  // string | 
            var minWidth = 1024;  // int? |  (optional) 
            var minHeight = 768;  // int? |  (optional) 
            var width = 1024;  // int? |  (optional) 
            var height = 768;  // int? |  (optional) 

            try
            {
                // Publish an item to Resource Store
                SelectAction result = apiInstance.Publish(url, pid, stoveData, minWidth, minHeight, width, height);
                Debug.WriteLine(result);
            }
            catch (ApiException  e)
            {
                Debug.Print("Exception when calling ResourceStoreApi.Publish: " + e.Message);
                Debug.Print("Status Code: " + e.ErrorCode);
                Debug.Print(e.StackTrace);
            }
        }
    }
}
```

#### Using the PublishWithHttpInfo variant
This returns an ApiResponse object which contains the response data, status code and headers.

```csharp
try
{
    // Publish an item to Resource Store
    ApiResponse<SelectAction> response = apiInstance.PublishWithHttpInfo(url, pid, stoveData, minWidth, minHeight, width, height);
    Debug.Write("Status Code: " + response.StatusCode);
    Debug.Write("Response Headers: " + response.Headers);
    Debug.Write("Response Body: " + response.Data);
}
catch (ApiException e)
{
    Debug.Print("Exception when calling ResourceStoreApi.PublishWithHttpInfo: " + e.Message);
    Debug.Print("Status Code: " + e.ErrorCode);
    Debug.Print(e.StackTrace);
}
```

### Parameters

| Name | Type | Description | Notes |
|------|------|-------------|-------|
| **url** | **string** |  |  |
| **pid** | **int** |  |  |
| **stoveData** | **string** |  |  |
| **minWidth** | **int?** |  | [optional]  |
| **minHeight** | **int?** |  | [optional]  |
| **width** | **int?** |  | [optional]  |
| **height** | **int?** |  | [optional]  |

### Return type

[**SelectAction**](SelectAction.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | Accepted |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

<a id="recreatewebview"></a>
# **RecreateWebview**
> string RecreateWebview (int pid, string url)

Recreate the Webview App

### Example
```csharp
using System.Collections.Generic;
using System.Diagnostics;
using USGWebServices.Editor.ResourceStore.Api;
using USGWebServices.Editor.ResourceStore.Client;
using USGWebServices.Editor.ResourceStore.Model;

namespace Example
{
    public class RecreateWebviewExample
    {
        public static void Main()
        {
            Configuration config = new Configuration();
            config.BasePath = "/v1";
            var apiInstance = new ResourceStoreApi(config);
            var pid = 1234;  // int | 
            var url = https://example.com/;  // string | 

            try
            {
                // Recreate the Webview App
                string result = apiInstance.RecreateWebview(pid, url);
                Debug.WriteLine(result);
            }
            catch (ApiException  e)
            {
                Debug.Print("Exception when calling ResourceStoreApi.RecreateWebview: " + e.Message);
                Debug.Print("Status Code: " + e.ErrorCode);
                Debug.Print(e.StackTrace);
            }
        }
    }
}
```

#### Using the RecreateWebviewWithHttpInfo variant
This returns an ApiResponse object which contains the response data, status code and headers.

```csharp
try
{
    // Recreate the Webview App
    ApiResponse<string> response = apiInstance.RecreateWebviewWithHttpInfo(pid, url);
    Debug.Write("Status Code: " + response.StatusCode);
    Debug.Write("Response Headers: " + response.Headers);
    Debug.Write("Response Body: " + response.Data);
}
catch (ApiException e)
{
    Debug.Print("Exception when calling ResourceStoreApi.RecreateWebviewWithHttpInfo: " + e.Message);
    Debug.Print("Status Code: " + e.ErrorCode);
    Debug.Print(e.StackTrace);
}
```

### Parameters

| Name | Type | Description | Notes |
|------|------|-------------|-------|
| **pid** | **int** |  |  |
| **url** | **string** |  |  |

### Return type

**string**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | Accepted |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

<a id="restartunityproject"></a>
# **RestartUnityProject**
> void RestartUnityProject (string fullPath)

Restart Unity Project

### Example
```csharp
using System.Collections.Generic;
using System.Diagnostics;
using USGWebServices.Editor.ResourceStore.Api;
using USGWebServices.Editor.ResourceStore.Client;
using USGWebServices.Editor.ResourceStore.Model;

namespace Example
{
    public class RestartUnityProjectExample
    {
        public static void Main()
        {
            Configuration config = new Configuration();
            config.BasePath = "/v1";
            var apiInstance = new ResourceStoreApi(config);
            var fullPath = ;  // string | 

            try
            {
                // Restart Unity Project
                apiInstance.RestartUnityProject(fullPath);
            }
            catch (ApiException  e)
            {
                Debug.Print("Exception when calling ResourceStoreApi.RestartUnityProject: " + e.Message);
                Debug.Print("Status Code: " + e.ErrorCode);
                Debug.Print(e.StackTrace);
            }
        }
    }
}
```

#### Using the RestartUnityProjectWithHttpInfo variant
This returns an ApiResponse object which contains the response data, status code and headers.

```csharp
try
{
    // Restart Unity Project
    apiInstance.RestartUnityProjectWithHttpInfo(fullPath);
}
catch (ApiException e)
{
    Debug.Print("Exception when calling ResourceStoreApi.RestartUnityProjectWithHttpInfo: " + e.Message);
    Debug.Print("Status Code: " + e.ErrorCode);
    Debug.Print(e.StackTrace);
}
```

### Parameters

| Name | Type | Description | Notes |
|------|------|-------------|-------|
| **fullPath** | **string** |  |  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | OK |  -  |
| **400** | Bad Request |  -  |
| **401** | Unauthorized |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

<a id="selectaction"></a>
# **SelectAction**
> SelectAction SelectAction (string url, int pid)

Select an action to publish

### Example
```csharp
using System.Collections.Generic;
using System.Diagnostics;
using USGWebServices.Editor.ResourceStore.Api;
using USGWebServices.Editor.ResourceStore.Client;
using USGWebServices.Editor.ResourceStore.Model;

namespace Example
{
    public class SelectActionExample
    {
        public static void Main()
        {
            Configuration config = new Configuration();
            config.BasePath = "/v1";
            var apiInstance = new ResourceStoreApi(config);
            var url = https://example.com/;  // string | 
            var pid = 1234;  // int | 

            try
            {
                // Select an action to publish
                SelectAction result = apiInstance.SelectAction(url, pid);
                Debug.WriteLine(result);
            }
            catch (ApiException  e)
            {
                Debug.Print("Exception when calling ResourceStoreApi.SelectAction: " + e.Message);
                Debug.Print("Status Code: " + e.ErrorCode);
                Debug.Print(e.StackTrace);
            }
        }
    }
}
```

#### Using the SelectActionWithHttpInfo variant
This returns an ApiResponse object which contains the response data, status code and headers.

```csharp
try
{
    // Select an action to publish
    ApiResponse<SelectAction> response = apiInstance.SelectActionWithHttpInfo(url, pid);
    Debug.Write("Status Code: " + response.StatusCode);
    Debug.Write("Response Headers: " + response.Headers);
    Debug.Write("Response Body: " + response.Data);
}
catch (ApiException e)
{
    Debug.Print("Exception when calling ResourceStoreApi.SelectActionWithHttpInfo: " + e.Message);
    Debug.Print("Status Code: " + e.ErrorCode);
    Debug.Print(e.StackTrace);
}
```

### Parameters

| Name | Type | Description | Notes |
|------|------|-------------|-------|
| **url** | **string** |  |  |
| **pid** | **int** |  |  |

### Return type

[**SelectAction**](SelectAction.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | Accepted |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

<a id="sendprojectheartbeat"></a>
# **SendProjectHeartbeat**
> Heartbeat SendProjectHeartbeat (bool active, Heartbeat heartbeat = null)

Send project heartbeat

### Example
```csharp
using System.Collections.Generic;
using System.Diagnostics;
using USGWebServices.Editor.ResourceStore.Api;
using USGWebServices.Editor.ResourceStore.Client;
using USGWebServices.Editor.ResourceStore.Model;

namespace Example
{
    public class SendProjectHeartbeatExample
    {
        public static void Main()
        {
            Configuration config = new Configuration();
            config.BasePath = "/v1";
            var apiInstance = new ResourceStoreApi(config);
            var active = true;  // bool | 
            var heartbeat = new Heartbeat(); // Heartbeat |  (optional) 

            try
            {
                // Send project heartbeat
                Heartbeat result = apiInstance.SendProjectHeartbeat(active, heartbeat);
                Debug.WriteLine(result);
            }
            catch (ApiException  e)
            {
                Debug.Print("Exception when calling ResourceStoreApi.SendProjectHeartbeat: " + e.Message);
                Debug.Print("Status Code: " + e.ErrorCode);
                Debug.Print(e.StackTrace);
            }
        }
    }
}
```

#### Using the SendProjectHeartbeatWithHttpInfo variant
This returns an ApiResponse object which contains the response data, status code and headers.

```csharp
try
{
    // Send project heartbeat
    ApiResponse<Heartbeat> response = apiInstance.SendProjectHeartbeatWithHttpInfo(active, heartbeat);
    Debug.Write("Status Code: " + response.StatusCode);
    Debug.Write("Response Headers: " + response.Headers);
    Debug.Write("Response Body: " + response.Data);
}
catch (ApiException e)
{
    Debug.Print("Exception when calling ResourceStoreApi.SendProjectHeartbeatWithHttpInfo: " + e.Message);
    Debug.Print("Status Code: " + e.ErrorCode);
    Debug.Print(e.StackTrace);
}
```

### Parameters

| Name | Type | Description | Notes |
|------|------|-------------|-------|
| **active** | **bool** |  |  |
| **heartbeat** | [**Heartbeat**](Heartbeat.md) |  | [optional]  |

### Return type

[**Heartbeat**](Heartbeat.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | OK |  -  |
| **404** | Not Found - sessionId does not match any existing session |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


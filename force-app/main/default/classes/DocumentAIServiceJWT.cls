public without Sharing class DocumentAIServiceJWT {
    
    // Replace with your Service Account credentials
    public static final String CLIENT_EMAIL = 'resume-extractor@calm-snowfall-458018-s6.iam.gserviceaccount.com';
    public static final String PRIVATE_KEY = '-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCuAWiRFfty3w9b\nyfVO9mISQ61nDDl8AQlo8CuZW7FWNQL+A6PlvkEo09h+hhqLQf6Bk8XbfR65MLPY\nG41NJ0tvZsekT6il3I28i+PNEisHK4hjGnFCoTnoHUr4jh/Ej+jJFnoscyt3QSx5\nSXqPhRAFKkUqchvLF8Zhb/rTs7eMN8B5vvkjR4MSgjrA5EYC2cy7dbdT+LJEMhIa\n7Hdx1n5lTINlZ6nhziKRrVVU8tK28ZqppYNi7Y1twQRTUeMgvi+oCsoQsgMSK/YR\nVNPcPhhYg/o/6UnjtB5SlQvqAA7/Cv5MKUppXSQrK2qVtTEeSFyHazKbnaJZaGqa\nDsgKZp7ZAgMBAAECggEAARHrJbE/6ZXrj0HvqzuioMAfydluZQ/Qkf+gFQJWVdRf\nn1ZAZMJFvk2HMEf808xlF0DkX5QmYzckc/i/ZrEOKrI0GhOPUu3HRViK3xD0iMfA\nv/NCrQk2xPGhK2QcV+YWpV3pBGr04nfZISnNgiJsVcvLvxYSi64qvyCkJzccstUG\nVfMifSW0eQ8+Wc0EJHqICfXyacFmmtY3lzht+kvt6/C+4xtHJLzyGfzPOeaB44pe\nJNw4kj5uxUkMrirwYXZbTAq5/AzlZXMlo+SJjUjbxa8V9l+62qK64hRAfcwkDO5b\ndIfA3bzbBTQ8P0NlKI41Fr2CdGGpUsz44RkL919VAQKBgQDblsq/k6+cFxb+/7bv\nIGobOsii/JUyD1Oj4gtkIBTpYltIKoIcC/YtHW9Cb0GmLyBIig8qFh7nCSLxdCnv\nijzMSRofHjE3/u0of+zcPBduz5Xw9ZuMloIUXCZagqb9AqWljnb62fY1tyD5yda6\n1I0Qb9GIk78YbMuK5kZPRGy3uQKBgQDK26rk5Tog8CotwE8K+iWtYOxdlR/v22np\nLhE6Ph91VRlcWzBaXv9yAK+lL4x20pzL8Z5VMX1UoHGhBshRWQ3tmV3pV5TWSipr\nFMmC2veeZC0mOBPJxieLrAYm5BZ3k/VMvjMDBRjzf1AHqm3B6ZQjeGlDMRX94P2i\nCjjeJRJwIQKBgQCqzP+nRBi0MMGSVxTTq0LdKzwkipMB/Snxr0FtAAdEAV0/JNFP\nP36cWOjRo/hMaxuRUNG6yrn+uvyTEugLilsAC1xmF/XwuDl/5wE1zQftCUp3wpLb\nJ7bGX2b1v+pjokt2Gvow5Ji971OW94guimWvA0rYERPyy60GvVazEWX/AQKBgQCp\n86OXJRywH8WWkvkl3zDVstAUDy20jASNYRT50LYWXPdkUtmNvO0SG9UL9Wwe2JCY\npJLcGRxBXDIWkFIfJRbwKn9tUPzXE0e6cq3ovX6a6p6Q2IZrk2HqOHLm/kx8Xi8y\n3l5qd0jSJ6Vq5rQRs5lyphy6OFOOYYLc0OeX5UMvQQKBgDn4hjwj2W5Ud0Y9KeLo\nilYJPWmfox/K1lfGVnRb/IX4rGpIK2sSamo4ZW2ePwwvjWf2KEiQmVK1sBc0Tf3B\nyKj2qiM/FebjMd8tRgyHGEfTHyPXy38qQqsUWBy07dSxvb3twKd1f9GnEwNIT4/I\nKyRioZoinj5J42vdUwnsYJV0\n-----END PRIVATE KEY-----\n';
    public static final String TOKEN_URI = 'https://oauth2.googleapis.com/token';
    public static final String SCOPE = 'https://www.googleapis.com/auth/cloud-platform'; // Or documentai scope
    public static final String PROJECT_ID = 'calm-snowfall-458018-s6';
    public static final String PROCESSOR_ID = 'abdb0b8821f04975';

    public static String callDocumentAI(Id cvId) {
        String extractedText = '';
        String jwt = generateJWT();
        String accessToken = getAccessToken(jwt);
        if (accessToken != null) {
            // Now you have access_token, you can call Document AI API here
            System.debug('Access Token: ' + accessToken);
            
            ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE Id =: cvId LIMIT 1];
            Blob fileBlob = cv.VersionData;
            String base64File = EncodingUtil.base64Encode(fileBlob);
            
            Map<String, Object> rawDocument = new Map<String, Object>();
			rawDocument.put('content', base64File); // No spaces/newlines
			rawDocument.put('mimeType', 'application/pdf');
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('rawDocument', rawDocument);
            
            String requestBodyJSON = JSON.serialize(requestBody);
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://us-documentai.googleapis.com/v1/projects/' + PROJECT_ID + '/locations/us/processors/' + PROCESSOR_ID + ':process');
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(requestBodyJSON);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            String responseBody = res.getBody();
            //System.debug('Full Response Body: ' + responseBody);
        
            // Parse JSON
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        
            // Navigate to text
            // For Document AI, usually the extracted text is under: document.text
            if (jsonResponse.containsKey('document')) {
                Map<String, Object> document = (Map<String, Object>) jsonResponse.get('document');
                if (document.containsKey('text')) {
                    extractedText = (String) document.get('text');
                    System.debug('Extracted Text: ' + extractedText);
                } else {
                    System.debug('No text found inside document.');
                }
            } else {
                System.debug('No document found in response.');
            }
            return extractedText;
        }
        return null;
    }
    
    private static String generateJWT() {
        Long iat = DateTime.now().getTime() / 1000;
        Long exp = iat + 3600; // 1 hour
        
        Map<String, Object> header = new Map<String, Object>{
            'alg' => 'RS256',
                'typ' => 'JWT'
                };
                    
                    Map<String, Object> claimSet = new Map<String, Object>{
                        'iss' => CLIENT_EMAIL,
                            'scope' => SCOPE,
                            'aud' => TOKEN_URI,
                            'exp' => exp,
                            'iat' => iat
                            };
                                
        String encodedHeader = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(header))).replaceAll('=+$', '').replace('+', '-').replace('/', '_');
        String encodedClaimSet = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(claimSet))).replaceAll('=+$', '').replace('+', '-').replace('/', '_');
        
        
        String signatureBase = encodedHeader + '.' + encodedClaimSet;
        Blob privateKeyBlob = EncodingUtil.base64Decode(PRIVATE_KEY.replace('-----BEGIN PRIVATE KEY-----\n', '').replace('\n-----END PRIVATE KEY-----', '').replace('\n', ''));
        Blob signature = Crypto.sign('RSA-SHA256', Blob.valueOf(signatureBase), privateKeyBlob);
        String encodedSignature = EncodingUtil.base64Encode(signature).replaceAll('=+$', '').replace('+', '-').replace('/', '_');
        
        String jwt = signatureBase + '.' + encodedSignature;
        return jwt;
    }
    
    private static String getAccessToken(String jwt) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOKEN_URI);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=' + jwt);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) tokenResponse.get('access_token');
        } else {
            System.debug('Failed to get access token: ' + res.getBody());
            return null;
        }
    }
}
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:3000/")
$listener.Start()
Write-Host "Server running at http://localhost:3000"

$root = "D:\4bricks"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $path = $context.Request.Url.LocalPath
    if ($path -eq "/") { $path = "/index.html" }
    $file = Join-Path $root $path.TrimStart("/")
    
    if (Test-Path $file) {
        $ext = [System.IO.Path]::GetExtension($file)
        $types = @{
            ".html"="text/html"; ".css"="text/css"; ".js"="application/javascript"
            ".png"="image/png"; ".jpg"="image/jpeg"; ".jpeg"="image/jpeg"
            ".svg"="image/svg+xml"; ".ico"="image/x-icon"; ".webp"="image/webp"
        }
        $context.Response.ContentType = if ($types[$ext]) { $types[$ext] } else { "text/html" }
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $context.Response.ContentLength64 = $bytes.Length
        $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $context.Response.StatusCode = 404
        $msg = [System.Text.Encoding]::UTF8.GetBytes("Not found")
        $context.Response.OutputStream.Write($msg, 0, $msg.Length)
    }
    $context.Response.Close()
}

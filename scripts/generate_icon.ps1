Add-Type -AssemblyName System.Drawing

$iconPath = "E:\App Dev\Flutter\countify\assets\icon\countify_icon.png"

$bitmap = New-Object System.Drawing.Bitmap(512, 512)
$g = [System.Drawing.Graphics]::FromImage($bitmap)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# 1. Dark Background Fill
$rect = New-Object System.Drawing.Rectangle(0, 0, 512, 512)
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 9, 13, 22))
$g.FillRectangle($brush, $rect)

# 2. Outer Glowing Ring
$penOuter = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 0, 229, 255), 26)
$g.DrawArc($penOuter, 106, 106, 300, 300, 45, 270)

# 3. Inner Glowing Ring
$penInner = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 59, 130, 246), 18)
$g.DrawArc($penInner, 146, 146, 220, 220, 45, 270)

# 4. Center Core Bead
$centerBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 229, 255))
$g.FillEllipse($centerBrush, 236, 236, 40, 40)

# 5. Save PNG
$bitmap.Save($iconPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bitmap.Dispose()

Write-Output "SUCCESS: Generated 512x512 HD App Icon PNG at $iconPath"

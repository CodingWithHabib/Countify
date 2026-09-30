Add-Type -AssemblyName System.Drawing

$iconPath = "E:\App Dev\Flutter\countify\assets\icon\countify_icon.png"

$bitmap = New-Object System.Drawing.Bitmap(512, 512)
$g = [System.Drawing.Graphics]::FromImage($bitmap)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# 1. Dark Background Fill with Squircle Tile
$rect = New-Object System.Drawing.Rectangle(0, 0, 512, 512)
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 9, 13, 22))
$g.FillRectangle($brush, $rect)

# 2. Outer Neon Container Border
$penBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 0, 229, 255), 12)
$g.DrawArc($penBorder, 20, 20, 472, 472, 0, 360)

# 3. Outer Glowing Crescent 'C' Arc
$penOuter = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 0, 229, 255), 28)
$g.DrawArc($penOuter, 106, 106, 300, 300, 45, 270)

# 4. Inner Glowing Ring
$penInner = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 16, 185, 129), 18)
$g.DrawArc($penInner, 146, 146, 220, 220, 45, 270)

# 5. Inside 'C': 3 Ascending Growth Bar Charts
$barBrush1 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 229, 255))
$barBrush2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 16, 185, 129))
$barBrush3 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 59, 130, 246))

# Bar 1 (Short)
$g.FillRectangle($barBrush1, 200, 270, 24, 70)
# Bar 2 (Medium)
$g.FillRectangle($barBrush2, 244, 230, 24, 110)
# Bar 3 (Tall)
$g.FillRectangle($barBrush3, 288, 190, 24, 150)

# 6. Crown Accent Top
$crownBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 245, 158, 11))
$g.FillEllipse($crownBrush, 236, 68, 40, 40)

# 7. Save PNG
$bitmap.Save($iconPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bitmap.Dispose()

Write-Output "SUCCESS: Generated 512x512 HD Live App Icon PNG at $iconPath"

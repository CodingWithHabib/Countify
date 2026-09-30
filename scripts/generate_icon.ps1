Add-Type -AssemblyName System.Drawing

$iconPath = "E:\App Dev\Flutter\countify\assets\icon\countify_icon.png"

$bitmap = New-Object System.Drawing.Bitmap(512, 512)
$g = [System.Drawing.Graphics]::FromImage($bitmap)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# 1. Dark Obsidian Background Fill
$rect = New-Object System.Drawing.Rectangle(0, 0, 512, 512)
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 8, 12, 22))
$g.FillRectangle($brush, $rect)

# 2. Glowing Outer Squircle Frame
$penBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 0, 229, 255), 18)
$g.DrawArc($penBorder, 16, 16, 480, 480, 0, 360)

# 3. Outer Bold Glowing Crescent 'C' Arc
$penOuter = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 0, 229, 255), 36)
$g.DrawArc($penOuter, 80, 80, 352, 352, 45, 270)

# 4. Inner Emerald Accent Ring
$penInner = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 16, 185, 129), 22)
$g.DrawArc($penInner, 128, 128, 256, 256, 45, 270)

# 5. Inside 'C': 3 Bold 3D Ascending Bar Charts
$barBrush1 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 229, 255))
$barBrush2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 16, 185, 129))
$barBrush3 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 139, 92, 246))

# Bar 1 (Short)
$g.FillRectangle($barBrush1, 195, 260, 28, 90)
# Bar 2 (Medium)
$g.FillRectangle($barBrush2, 242, 210, 28, 140)
# Bar 3 (Tall)
$g.FillRectangle($barBrush3, 289, 160, 28, 190)

# 6. Crown Accent Top
$crownBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 245, 158, 11))
$g.FillEllipse($crownBrush, 236, 40, 40, 40)

# 7. Save PNG
$bitmap.Save($iconPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bitmap.Dispose()

Write-Output "SUCCESS: Generated 512x512 Bold HD Live App Icon PNG at $iconPath"

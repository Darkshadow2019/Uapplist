[Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8
$OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding
# Load the necessary .NET assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "About"
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = "CenterScreen"
$form.TopMost = $true 
$form.FormBorderStyle = "FixedSingle" # Prevents resizing

# Create a label to display text
$label = New-Object System.Windows.Forms.Label
$label.Text = "ယခု Online version 1.0.0.1 ကို`nသုံးရတာအဆင်ပြေရဲ့လားဗျာ?"
$label.Location = New-Object System.Drawing.Point(70, 30)
$label.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 10)
# $label.Font = New-Object System.Drawing.Font("Pyidaungsu", 16, [System.Drawing.FontStyle]::Bold)
$label.AutoSize = $true

# Create a button
$button = New-Object System.Windows.Forms.Button
$button.Text = "OK"
$button.Location = New-Object System.Drawing.Point(150, 120)
$button.Size = New-Object System.Drawing.Size(100, 30)

# Add an event handler for the button click
$button.Add_Click({
    # Change the label text when the button is clicked
    $label.Text = "အခုဒီ Dialog ကိုပိတ်လိုက်ရင်`Chrome ပွင့်လာပါမယ်`nပထမ Don't Sign in ကိုနိပ်ပါ `nဒုတိယ Skip ကိုနှိပ်ပြီး ခနစောင့်နေပါ`nimx Website (ဝဘ်ဆိုဒ်) ပွင့်လာပါလိမ့်မယ်ဗျာ။"
})

# Add the controls to the form
$form.Controls.Add($label)
$form.Controls.Add($button)

# Show the form

$form.ShowDialog()

# hide called console 
$window = Get-Process -Id $PID | Where-Object { $_.MainModule.ModuleName -match 'powershell.exe' }
if ($window) {
    $window.MainWindowHandle | Out-Win32Window
}
















# Load the necessary .NET assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "About"
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle" # Prevents resizing

# Create a label to display text
$label = New-Object System.Windows.Forms.Label
$label.Text = "WINDOWS TEMPORARY CLEANNER SCRIPT"
$label.Location = New-Object System.Drawing.Point(100, 50)
$label.AutoSize = $true
$label.Font = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)

# Create a button
$button = New-Object System.Windows.Forms.Button
$button.Text = "OK"
$button.Location = New-Object System.Drawing.Point(150, 100)
$button.Size = New-Object System.Drawing.Size(100, 30)

# Add an event handler for the button click
$button.Add_Click({
    # Change the label text when the button is clicked
    $label.Text = "Button was clicked!"
})

# Add the controls to the form
$form.Controls.Add($label)
$form.Controls.Add($button)

# Show the form

$form.ShowDialog()


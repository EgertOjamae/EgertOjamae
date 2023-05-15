     
########################Add Types###################################################
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
 
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$ErrorActionPreference = "SilentlyContinue"
 
$Runspace = [runspacefactory]::CreateRunspace()
$Runspace.ApartmentState = "STA"
$Runspace.ThreadOptions = "ReuseThread"
$Runspace.Open()
 
$code = {
 
 
#Find the primary monitor
$Monitor = [System.Windows.Forms.Screen]::AllScreens | Where-Object {$_.Primary -Like "True"}
 
#Set Window position based on the primary monitor's resolution.
$Global:Left = $Monitor.bounds.Width - 345
$Global:Top = $Monitor.bounds.Height #Curretnly not using this because it's just easier to set the absolute value in the XAML below.
 
[xml]$xaml = @"
<Window
 xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
 xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" x:Name="Window_Main"
 
 Title="BGInfo" ShowInTaskbar="False" Focusable="False" ResizeMode="NoResize" WindowStyle="None" Left="$Left" Top="20" RenderTransformOrigin="0.5,0.5" Height="45" Width="250">
 <Grid Background="#FF070707" AllowDrop="True">
 <TextBlock x:Name="TextBlock_ComputerName" Height="40" Grid.Column="0" Grid.Row="0" VerticalAlignment="Bottom" Margin="9.5,0,9.5,6" Foreground="White" HorizontalAlignment="Left" FontSize="14">
     <Run Text="Computer Name: LAAA0000AAA0000" />
     <LineBreak />
     <Run Text="IP Address(es):     10.120.120.120. 10.120.120.120." />
     <LineBreak />
     <LineBreak />
 </TextBlock>
 <Button Content="Button" IsTabStop="False" x:Name="Button_1" Height="11" Width="24" Opacity="0" RenderTransformOrigin="0.5417,0.5" Grid.Column="0" Grid.Row="0" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,218,29.5" />
 <Button Content="Button" IsTabStop="False" Width="25" Height="15" x:Name="Button_2" Opacity="0" RenderTransformOrigin="0.5,0.5" Grid.Column="0" Grid.Row="0" HorizontalAlignment="Left" VerticalAlignment="Bottom" Margin="2,0,0,-1.5" />
</Grid>
</Window>
"@
 
$syncHash = [hashtable]::Synchronized(@{})
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$syncHash.Window=[Windows.Markup.XamlReader]::Load( $reader )
 
$SyncHash.TextBlock_ComputerName = $SyncHash.Window.FindName("TextBlock_ComputerName")
#These buttons are only here as a hidden method to conveniently close this window
$SyncHash.Button_1 = $SyncHash.Window.FindName("Button_1")
$SyncHash.Button_2 = $SyncHash.Window.FindName("Button_2")
 
 
#These buttons will close the window if clicked within the right order within a certain time.
$SyncHash.Button_1.Add_Click({
    $Global:FirstClickTime = (Get-Date) + (New-TimeSpan -Seconds 3)
})
 
$SyncHash.Button_2.Add_Click({
    IF ((Get-Date) -Lt $Global:FirstClickTime) {$SyncHash.Window.Close()}
    
})
 
$syncHash.Host = $host
$Runspace = [runspacefactory]::CreateRunspace()
$Runspace.ApartmentState = "STA"
$Runspace.ThreadOptions = "ReuseThread"
$Runspace.Open()
$Runspace.SessionStateProxy.SetVariable("syncHash",$syncHash) 
 
 
$code = {
    Do {
    $IPAddresses = (Get-NetIPAddress | Where-Object {$_.AddressFamily -Eq "IPv4"} | Where-Object {$_.InterFaceAlias -Eq "Wi-Fi" -Or $_.InterFaceAlias -Eq "Ethernet"} | Where-Object {$_.AddressState -Eq "Preferred"}).IPAddress
    #Set the contents of the Text Block
    $SyncHash.TextBlock_ComputerName.Dispatcher.invoke([action]{
    $SyncHash.TextBlock_ComputerName.Text = "Computer Name: $Env:COMPUTERNAME
Active IP Address: $IPAddresses"
    })
    Start-Sleep 10
    } Until (1 -eq 2)
}#End of Code Block
 
$PSinstance = [powershell]::Create().AddScript($Code)
$PSinstance.Runspace = $Runspace
$job = $PSinstance.BeginInvoke()#
 
 
$SyncHash.Window.ShowDialog()
 
 
    }#End of Code Block
 
    $PSinstance = [powershell]::Create().AddScript($Code)
    $PSinstance.Runspace = $Runspace
    $job = $PSinstance.BeginInvoke()
RAW Paste Data
########################Add Types###################################################
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$ErrorActionPreference = "SilentlyContinue"

$Runspace = [runspacefactory]::CreateRunspace()
$Runspace.ApartmentState = "STA"
$Runspace.ThreadOptions = "ReuseThread"
$Runspace.Open()

$code = {


#Find the primary monitor
$Monitor = [System.Windows.Forms.Screen]::AllScreens | Where-Object {$_.Primary -Like "True"}

#Set Window position based on the primary monitor's resolution.
$Global:Left = $Monitor.bounds.Width - 345
$Global:Top = $Monitor.bounds.Height #Curretnly not using this because it's just easier to set the absolute value in the XAML below.

[xml]$xaml = @"
<Window
 xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
 xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" x:Name="Window_Main"
 
 Title="BGInfo" ShowInTaskbar="False" Focusable="False" ResizeMode="NoResize" WindowStyle="None" Left="$Left" Top="20" RenderTransformOrigin="0.5,0.5" Height="45" Width="250">
 <Grid Background="#FF070707" AllowDrop="True">
 <TextBlock x:Name="TextBlock_ComputerName" Height="40" Grid.Column="0" Grid.Row="0" VerticalAlignment="Bottom" Margin="9.5,0,9.5,6" Foreground="White" HorizontalAlignment="Left" FontSize="14">
     <Run Text="Computer Name: LAAA0000AAA0000" />
     <LineBreak />
     <Run Text="IP Address(es):     10.120.120.120. 10.120.120.120." />
     <LineBreak />
     <LineBreak />
 </TextBlock>
 <Button Content="Button" IsTabStop="False" x:Name="Button_1" Height="11" Width="24" Opacity="0" RenderTransformOrigin="0.5417,0.5" Grid.Column="0" Grid.Row="0" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,218,29.5" />
 <Button Content="Button" IsTabStop="False" Width="25" Height="15" x:Name="Button_2" Opacity="0" RenderTransformOrigin="0.5,0.5" Grid.Column="0" Grid.Row="0" HorizontalAlignment="Left" VerticalAlignment="Bottom" Margin="2,0,0,-1.5" />
</Grid>
</Window>
"@
 
$syncHash = [hashtable]::Synchronized(@{})
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$syncHash.Window=[Windows.Markup.XamlReader]::Load( $reader )
 
$SyncHash.TextBlock_ComputerName = $SyncHash.Window.FindName("TextBlock_ComputerName")
#These buttons are only here as a hidden method to conveniently close this window
$SyncHash.Button_1 = $SyncHash.Window.FindName("Button_1")
$SyncHash.Button_2 = $SyncHash.Window.FindName("Button_2")


#These buttons will close the window if clicked within the right order within a certain time.
$SyncHash.Button_1.Add_Click({
    $Global:FirstClickTime = (Get-Date) + (New-TimeSpan -Seconds 3)
})

$SyncHash.Button_2.Add_Click({
    IF ((Get-Date) -Lt $Global:FirstClickTime) {$SyncHash.Window.Close()}
    
})

$syncHash.Host = $host
$Runspace = [runspacefactory]::CreateRunspace()
$Runspace.ApartmentState = "STA"
$Runspace.ThreadOptions = "ReuseThread"
$Runspace.Open()
$Runspace.SessionStateProxy.SetVariable("syncHash",$syncHash) 


$code = {
    Do {
    $IPAddresses = (Get-NetIPAddress | Where-Object {$_.AddressFamily -Eq "IPv4"} | Where-Object {$_.InterFaceAlias -Eq "Wi-Fi" -Or $_.InterFaceAlias -Eq "Ethernet"} | Where-Object {$_.AddressState -Eq "Preferred"}).IPAddress
    #Set the contents of the Text Block
    $SyncHash.TextBlock_ComputerName.Dispatcher.invoke([action]{
    $SyncHash.TextBlock_ComputerName.Text = "Computer Name: $Env:COMPUTERNAME
Active IP Address: $IPAddresses"
    })
    Start-Sleep 10
    } Until (1 -eq 2)
}#End of Code Block

$PSinstance = [powershell]::Create().AddScript($Code)
$PSinstance.Runspace = $Runspace
$job = $PSinstance.BeginInvoke()#


$SyncHash.Window.ShowDialog()


    }#End of Code Block

    $PSinstance = [powershell]::Create().AddScript($Code)
    $PSinstance.Runspace = $Runspace
    $job = $PSinstance.BeginInvoke()

# define the path to the Users disk
$usersPath = "U:\"

# define the name of the folders that contain user profiles
$profilesFolderName = "profiles"

# define the path where profiles should be moved
$destinationPath = "A:\!delete\profiles"

# get a list of all disabled user accounts in the domain
$disabledUsers = Get-ADUser -Filter {Enabled -eq $false}

# create an empty array to store the matching profile folders
$matchingProfiles = @()

# loop through each disabled user account
foreach ($user in $disabledUsers) {
    # get the user's logon name
    $logonName = $user.sAMAccountName.ToLower()

    # construct the path to the user's profile folder
    $profilePath = Join-Path -Path (Join-Path -Path $usersPath -ChildPath $profilesFolderName) -ChildPath "$logonName.V6"

    # check if the profile folder exists
    if (Test-Path $profilePath) {
        # add the profile folder to the list of matching profiles
        $matchingProfiles += $profilePath
        Write-Host "Found matching profile folder: $profilePath"
    }
}

# display the number of matching profiles found
Write-Host "Found $($matchingProfiles.Count) matching profiles."

# ask the user if they want to continue
$continue = Read-Host "Do you want to continue? (Y/N)"

# check if the user wants to continue
if ($continue.ToLower() -eq "y") {
    # loop through each matching profile folder and move it to the destination path
    foreach ($profile in $matchingProfiles) {
        # get the username from the profile folder name
        $username = $profile.Split("\")[-1].Split(".")[0]

        Write-Host "Moving profile folder for $username" -BackgroundColor Yellow
        Move-Item -Path $profile -Destination $destinationPath -Force
        Write-Host "Profile folder for $username has been moved" -BackgroundColor Green
    }

    # display a message indicating the profiles were moved successfully
    Write-Host "Profiles moved successfully to $destinationPath." -BackgroundColor Red
} else {
    # display a message indicating the user chose not to continue
    Write-Host "Script aborted."
}

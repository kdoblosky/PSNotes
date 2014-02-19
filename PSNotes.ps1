# Where to store notebooks if no path is provided
$DefaultNotePath = "D:\Notes"

# Where to store list of notebooks
$NoteBookList = Join-Path $DefaultNotePath NotesList.json

Function Get-Notebooks([switch]$Force) {

    # Make sure there is a variable defined for NoteBookList
    try {
        Get-Variable NoteBookList -ErrorAction Stop | Out-Null
    } catch {
        throw "`$NoteBookList is undefined. It should contain a path to a file containing json formatted list of notebooks."
    }

    $notebooks = @{}
    if (! (Test-Path $NoteBookList) ) {
        if ($Force) {
            try {
                Write-Host "Notebook list doesn't exist. Creating it at $NoteBookList..."
                New-Item $NoteBookList -ItemType File -Force -ErrorAction Stop | Out-Null
            } catch {
                throw "Error creating NoteBookList at $NoteBookList"
            }
        } else {
            throw "Notebook list not found at $NoteBookList"
        }
    } else {
        try {
            (Get-Content $NoteBookList -Raw | ConvertFrom-Json).PSObject.Properties | ForEach-Object { 
                $notebooks[$_.Name] = $_.Value 
            }
        } catch {
            # Need to validate this, for now ignoring any errors, so that it will return an empty hash
        }
    }

    $notebooks
}

Function Get-NotebookPath ($Alias) {
    # TODO: Handle any errors from Get-Notebooks
    $notebooks = Get-Notebooks
    $notebooks[$Alias]
}

Function Add-Notebook($Alias, $NotebookPath) {
    # Get Existing Notebooks
    $notebooks = Get-Notebooks

    # Create $notebooks if it doesn't already exist
    if ($notebooks -eq $null) { $notebooks = @{} }

    $notebooks[$Alias] = $NotebookPath

    $notebooks | ConvertTo-Json | Set-Content $NoteBookList
}

Function Get-Notes($Notebook) {
    $notebooks = Get-Notebooks
    
    if ($notebooks.ContainsKey($Notebook)) {
        Get-Content $notebooks[$Notebook]
    } else {
        "Notebook does not exist"
    }
}

Function Add-NewNote {
    param(
        $Notebook,
        $Note,
        [switch]$Force
    )

    $NotebookPath = Get-NotebookPath $Notebook

    if ($NotebookPath -eq $null) {
        if ($Force) {
            Write-Host "Notebook doesn't exist. Creating it."
            $NotebookPath = Join-Path $DefaultNotePath "$Notebook.txt"
            New-Item $NotebookPath -ItemType File -Force | Out-Null
            Add-Notebook $Notebook $NotebookPath
        }
        else {
            throw "Notebook doesn't exist"
        }
    }

    $datestamp = (Get-Date).ToString("yyyy-MM-dd")
    Add-Content -Path $NotebookPath -Value "$datestamp - $Note"
}

New-Alias -Name note -Value Add-NewNote
New-Alias -Name anb -Value Add-Notebook
New-Alias -Name gn -Value Get-Notes
New-Alias -Name nbs -Value Get-Notebooks
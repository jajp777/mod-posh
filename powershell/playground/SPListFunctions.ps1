Add-PSSnapin microsoft.sharepoint.powershell -ErrorAction SilentlyContinue

<#
    .Synopsis
    Returns information for a specifc list that matches the given criteria.    
    .Example
    Get-SPList -Url http://sp -Title "Pages"
    Returns information on the Pages library from the root web of the site collection at http://sp. The SchemaXML field is not shown in the displayed list properties.
    .Example
    Get-SPList -Url http://sp -Title "Pages" -IncludeSchemaXML:$True
    Returns information on the Pages library from the root web of the site collection at http://sp. Include the SchemaXML field in the displayed list properties.
#>
function Get-SPList($Url,[String]$Title,[Switch]$IncludeSchemaXML=$False) 
{    
    $site = new-object Microsoft.SharePoint.SPSite $Url
    $web = $site.OpenWeb()
    $list = $Web.Lists[$Title]
    
    if ($list -eq $null)
    {
        write-host "Unable to open list" $Title "at" $Url -foregroundcolor red
    }
    else
    {
        write-host "Getting list" $Title "at" $Url "..."
    }
    
    if ($IncludeSchemaXML)
    {
        $list | format-list ID,Title,Description,ItemCount,Views,DefaultViewUrl,BaseType,BaseTemplate,LastItemModifiedDate,ContentTypes,Fields,SchemaXml
    }
    else
    {
        $list | format-list ID,Title,Description,ItemCount,Views,DefaultViewUrl,BaseType,BaseTemplate,LastItemModifiedDate,ContentTypes,Fields
    }       
}

<#
    .Synopsis
    Returns information for lists that match the given criteria.     
    .Example
    Get-SPLists -Url http://sp
    Returns a table of the lists in the site collection http://sp. Common lists and lists with no items are not included.
    .Example
    Get-SPLists -Url http://sp -HideCommonLists:$False -HideEmptyLists:$False
    Returns a table of the lists in the site collection http://sp. Common lists and lists with no items will be included.
#>
function Get-SPLists([Microsoft.SharePoint.SPSite]$Url,[Switch]$HideCommonLists=$True,[Switch]$HideEmptyLists=$True)
{
    $site = Get-SPSite $Url
    write-host "Getting lists for" $Url "..."
    $lists = $site.Allwebs | ForEach {$_.Lists}
    
    if ($HideCommonLists)
    {         
        write-host " - Common lists are excluded from the results"
        $lists = $lists | ? {$_.BaseTemplate -notmatch "UserInformation"}
        $lists = $lists | ? {$_.BaseTemplate -notmatch "WebPartCatalog"}
        $lists = $lists | ? {$_.BaseTemplate -notmatch "ListTemplateCatalog"}
        $lists = $lists | ? {$_.BaseTemplate -notmatch "MasterPageCatalog"}
        $lists = $lists | ? {$_.BaseTemplate -notmatch "SolutionCatalog"}
        $lists = $lists | ? {$_.BaseTemplate -notmatch "NoCodePublic"}
        $lists = $lists | ? {$_.BaseTemplate -notmatch "ThemeCatalog"}
    }
    
    If ($HideEmptyLists)
    {
        write-host " - Lists with no items are excluded from the results"
        $lists = $lists | ? {$_.ItemCount -ne 0}
    }

    write-host "Found a total of"$lists.Count "lists"
    $lists | Sort ParentWebUrl,Title | FT Title,ParentWebUrl,ItemCount -AutoSize
}

<#
    .Synopsis
    Returns the lists that match the given criteria, grouped by the BaseTemplate list property.
    .Example
    Get-SPListsByTemplate -Url http://sp
    Returns a table of the lists in the site collection http://sp grouped by template type. Common lists and lists with no items are not included.
    .Example
    Get-SPListsByTemplate -Url http://sp -HideCommonLists:$False -HideEmptyLists:$False
    Returns a table of the lists in the site collection http://sp grouped by template type. Common lists and lists with no items will be included.
#>
function Get-SPListsByTemplate([Microsoft.SharePoint.SPSite]$Url,[Switch]$HideCommonLists=$True,[Switch]$HideEmptyLists=$True) 
{
    $site = Get-SPSite $Url
    write-host "Getting lists for" $Url "..."
    $lists = $site.Allwebs | ForEach {$_.Lists}
    
    if ($HideCommonLists)
    {         
        write-host " - Common lists are excluded from the results"
        $lists = $lists | ? {$_.BaseTemplate -notmatch "UserInformation"}
        $lists = $lists | ? {$_.BaseTemplate -notmatch "WebPartCatalog"}
        $lists = $lists | ? {$_.BaseTemplate -notmatch "ListTemplateCatalog"}
        $lists = $lists | ? {$_.BaseTemplate -notmatch "MasterPageCatalog"}
        $lists = $lists | ? {$_.BaseTemplate -notmatch "SolutionCatalog"}
        $lists = $lists | ? {$_.BaseTemplate -notmatch "NoCodePublic"}
        $lists = $lists | ? {$_.BaseTemplate -notmatch "ThemeCatalog"}
    }
    
    If ($HideEmptyLists)
    {
        write-host " - Lists with no items are excluded from the results"
        $lists = $lists | ? {$_.ItemCount -ne 0}
    }

    write-host "Found a total of"$lists.Count "lists"
    $lists | Group-Object -Property BaseTemplate | Sort Count -Descending | FT Count,Name -Autosize
}
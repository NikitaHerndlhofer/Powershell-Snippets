param($url, $project, $pat, $svnuser, $svnpassword)
echo $pat | az devops login --org $url
$buildDefinitions = (az pipelines build definition list --org $url --project $project) | convertfrom-json
foreach ($buildDefinition in $buildDefinitions){
    
    $variables = az pipelines variable list --detect true --pipeline-id $buildDefinition.id --project $project | convertfrom-json

    if ($variables.buildCI.Value -eq $True){
    
        $pipeline = az pipelines build definition show --detect true --id $buildDefinition.id --project $project| convertfrom-json
        $svnPath = $pipeline.repository.url + '/' + $pipeline.repository.defaultBranch
        $lastBuildRevision = [int](az pipelines build list --project $project --definition-ids $buildDefinition.id --status all --top 1| convertfrom-json)[0].sourceVersion

        $svnInfo =  svn info $svnPath --username $svnuser --password $svnpassword
        $svnRevision = [int](-split $svnInfo.where{$_ -match 'Last Changed Rev*'})[3]


        if ($svnRevision -gt $lastBuildRevision){
            az pipelines build queue --detect true --definition-id $buildDefinition.id --project $project
            }
    } 
}
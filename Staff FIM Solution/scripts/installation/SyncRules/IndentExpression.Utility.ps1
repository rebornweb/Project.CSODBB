cls
#$expression = 'IIF(Eq(employeeStatus,"Active"),IIF(IsPresent(pwdLastSet),IIF(Eq(pwdLastSet,0),userAccountControl,BitAnd(-3,userAccountControl)),userAccountControl),IIF(IsPresent(employeeStatusHR),IIF(Eq(employeeStatusHR,"Active"),IIF(IsPresent(pwdLastSet),IIF(Eq(pwdLastSet,0),userAccountControl,BitAnd(-3,userAccountControl)),userAccountControl),BitOr(2,userAccountControl)),BitOr(2,userAccountControl)))'
$expression = '[IIF(CustomExpression(IsPresent(userAccountControl)),CustomExpression(IIF(Eq(employeeStatus,"Active"),IIF(IsPresent(pwdLastSet),IIF(Eq(pwdLastSet,0),userAccountControl,BitAnd(-3,userAccountControl)),userAccountControl),IIF(IsPresent(employeeStatusHR),IIF(Eq(employeeStatusHR,"Active"),IIF(IsPresent(pwdLastSet),IIF(Eq(pwdLastSet,0),userAccountControl,BitAnd(-3,userAccountControl)),userAccountControl),BitOr(2,userAccountControl)),BitOr(2,userAccountControl)))),514)]'
$expression = '[IIF(CustomExpression(
IsPresent(userAccountControl)),
    CustomExpression(
    IIF(Eq(employeeStatus,"Active"),
        IIF(IsPresent(employeeStatusHR),
            IIF(Eq(employeeStatusHR,"Active"),
                IIF(IsPresent(pwdLastSet),
                    IIF(Eq(pwdLastSet,0),
                        userAccountControl,
                        BitAnd(-3,userAccountControl)),
                    userAccountControl),
                BitOr(2,userAccountControl)),
            BitOr(2,userAccountControl))),
        IIF(IsPresent(pwdLastSet),
            IIF(Eq(pwdLastSet,0),
                userAccountControl,
                BitAnd(-3,userAccountControl)),
            userAccountControl)),
            514)]'
$expression = '[IIF(CustomExpression(Eq(employeeStatus,"Active")),CustomExpression(IIF(Eq(Right(dnAD,58),",OU=Old Users,OU=Users,OU=ORG,DC=originenergy,DC=com,DC=au"),+(EscapeDNComponent(+("CN=",accountName)),",OU=Provisioned User Accounts,DC=originenergy,DC=com,DC=au"),dnAD)),CustomExpression(+(EscapeDNComponent(+("CN=",accountName)),",OU=Old Users,OU=Users,OU=ORG,DC=originenergy,DC=com,DC=au")))]'
$expression = 'IIF(isNetworkAccessRequired,IIF(IsPresent(pwdLastSet),IIF(Eq(pwdLastSet,0),userAccountControl,BitAnd(-3,userAccountControl)),userAccountControl),IIF(IsPresent(employeeStatusHR),IIF(Eq(employeeStatusHR,"Active"),IIF(IsPresent(pwdLastSet),IIF(Eq(pwdLastSet,0),userAccountControl,BitAnd(-3,userAccountControl)),userAccountControl),BitOr(2,userAccountControl)),BitOr(2,userAccountControl)))'

function GetTabs([int]$count) {
    $tabIntent = ""
    for($tabCount=0; $tabCount -lt $count; $tabCount++) {
        $tabIntent += $oneTab
    }
    $tabIntent
}

#indent an IIF expression to align embedded IIFs
$indentCount = 0
$expIndex = 0
$expressionResult = ""
$oneTab = "    "
$nl = [Environment]::NewLine
$tabIntent = ""
$lastChar = ""
while($expIndex -lt $expression.Length) {
    $lastChar = $thisChar
    $thisChar = $expression.Substring($expIndex,1)
    $expressionResult += $thisChar
    if ($thisChar -eq "(") {
        $indentCount += 1
        $expressionResult += $nl + $(GetTabs -count $indentCount)
    }
    if ($thisChar -eq ")") {
        $indentCount -= 1
        $expressionResult += $nl + $(GetTabs -count $indentCount)
    } elseif ($expression.Substring($expIndex,1) -eq ",") {
        $expressionResult += $nl + $(GetTabs -count $indentCount)
    }
    $expIndex += 1
}
$expressionResult
$expressionResult.Replace($nl,"").Replace(" ","")


'[IIF(
    CustomExpression(
        IsPresent(
            userAccountControl)
        )
    ,
    CustomExpression(
        IIF(
            Eq(
                employeeStatus,
                "Active")
            ,
            IIF(
                IsPresent(
                    employeeStatusHR)
                ,
                IIF(
                    Eq(
                        employeeStatusHR,
                        "Active")
                    ,
                    IIF(
                        IsPresent(
                            pwdLastSet)
                        ,
                        IIF(
                            Eq(
                                pwdLastSet,
                                0)
                            ,
                            userAccountControl,
                            BitAnd(
                                -3,
                                userAccountControl)
                            )
                        ,
                        userAccountControl)
                    ,
                    BitOr(
                        2,
                        userAccountControl)
                    )
                ,
                BitOr(
                    2,
                    userAccountControl)
                )
            )
            ,
            IIF(
                IsPresent(
                    pwdLastSet)
                ,
                IIF(
                    Eq(
                        pwdLastSet,
                        0)
                    ,
                    userAccountControl,
                    BitAnd(
                        -3,
                        userAccountControl)
                    )
                ,
                userAccountControl)
        )
    ,
    514)
]'.Replace($nl,"").Replace(" ","")

$ActiveDN = '    CustomExpression(
        IIF(Eq(Right(dnAD,58),",OU=OldUsers,OU=Users,OU=ORG,DC=originenergy,DC=com,DC=au"),Concatenate(EscapeDNComponent(Concatenate("CN=",accountName)),",OU=ProvisionedUserAccounts,DC=originenergy,DC=com,DC=au"),dnAD)
'
$InactiveDN = '    CustomExpression(
        Concatenate(EscapeDNComponent(+("CN=",accountName)),",OU=ProvisionedUserAccounts,DC=originenergy,DC=com,DC=au")
'

'IIF(
            Eq(
                Right(
                    dnAD,
                    58)
                ,
                ",
                OU=Old Users,
                OU=Users,
                OU=ORG,
                DC=originenergy,
                DC=com,
                DC=au")
            ,
            +(
                EscapeDNComponent(
                    +(
                        "CN=",
                        accountName)
                    )
                ,
                ",
                OU=Provisioned User Accounts,
                DC=originenergy,
                DC=com,
                DC=au")
            ,
            dnAD)'.Replace($nl,"").Replace(" ","")

'+(
                EscapeDNComponent(
                    +(
                        "CN=",
                        accountName)
                    )
                ,
                ",
                OU=Provisioned User Accounts,
                DC=originenergy,
                DC=com,
                DC=au")'.Replace($nl,"").Replace(" ","")

# if AD object exists

'[IIF(
    CustomExpression(
        IsPresent(
            userAccountControl)
        )
    ,
    CustomExpression(
        IIF(
            Eq(
                employeeStatus,
                "Active")
            ,
            IIF(
                IsPresent(
                    employeeStatusHR)
                ,
                IIF(
                    Eq(
                        employeeStatusHR,
                        "Active")
                    ,
                    $ActiveDN
                    ,
                    $InactiveDN
                ,
                $ActiveDN
            )
        ,
        IIF(
            IsPresent(
                pwdLastSet)
            ,
            IIF(
                Eq(
                    pwdLastSet,
                    0)
                ,
                userAccountControl,
                BitAnd(
                    -3,
                    userAccountControl)
                )
            ,
            userAccountControl)
        )
    ,
    $InactiveDN)
]'


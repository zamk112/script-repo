Global $SQLConn = ObjCreate("ADODB.Connection")
Global $SQLRecordSet = ObjCreate("ADODB.Recordset")
$oMyError = ObjEvent("AutoIt.Error","MyErrFunc")

$server = "localhost"
$db = "mylocaldb"
$username = "___USER_NAME___"
$password = "___PASSWORD___"
$sqlString = "SELECT * FROM mytable"

With $SQLConn
.Provider = "SQLOLEDB.1"
	.Properties("Initial Catalog") = $db
	.Properties("Data Source").Value = $server
    	;.Properties("Integrated Security").Value = "SSPI"
    	;.Properties("Persist Security Info").Value = "True"
    	.Properties("User ID").Value = $username
    	.Properties("Password").Value = $password
    	.Open
EndWith
$SQLRecordSet.Open($sqlString,$SQLConn)
Local $result = $SQLRecordSet.GetString
ConsoleWrite($result)

;#comments-start
; This is my custom defined error handler
Func MyErrFunc()
	Local $strErrorMessage = "We intercepted a COM Error !"      & @CRLF  & @CRLF & _
             "err.description is: "    & @TAB & $oMyError.description    & @CRLF & _
             "err.windescription:"     & @TAB & $oMyError.windescription & @CRLF & _
             "err.number is: "         & @TAB & hex($oMyError.number,8)  & @CRLF & _
             "err.lastdllerror is: "   & @TAB & $oMyError.lastdllerror   & @CRLF & _
             "err.scriptline is: "     & @TAB & $oMyError.scriptline     & @CRLF & _
             "err.source is: "         & @TAB & $oMyError.source         & @CRLF & _
             "err.helpfile is: "       & @TAB & $oMyError.helpfile       & @CRLF & _
             "err.helpcontext is: "    & @TAB & $oMyError.helpcontext

	  ;Msgbox(0,"AutoItCOM Test", $strErrorMessage)
	  ConsoleWrite($strErrorMessage)
    Local $err = $oMyError.number
    If $err = 0 Then $err = -1

    SetError($err)  ; to check for after this function returns
Endfunc

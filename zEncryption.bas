Attribute VB_Name = "zEncryption"
Option Compare Database
'Description: Turns strings into a hash that can not be turned back into the original string
'Use Case: For passwords. When a user creates a password, do password = SHA(userInput)
'This stores the hash. When the user wants to login, do
'If SHA(userInput) = password then
    'login = successful
'Else
    'login = unsuccessful
'end if

Function SHA(ByVal sMessage)
    Dim i, temp(8) As Double, fraccubeprimes, hashValues
    Dim done512, index512, words(64) As Double, index32, mask(4)
    Dim s0, s1, t1, t2, maj, ch, strLen
    'dim result(32) --> changed so a string is returned instead of an array
    Dim result As String
    
    timeStart = Now()
    mask(0) = 4294967296#
    mask(1) = 16777216
    mask(2) = 65536
    mask(3) = 256
 
    hashValues = Array( _
        1779033703, 3144134277#, 1013904242, 2773480762#, _
        1359893119, 2600822924#, 528734635, 1541459225)
 
    fraccubeprimes = Array( _
        1116352408, 1899447441, 3049323471#, 3921009573#, 961987163, 1508970993, 2453635748#, 2870763221#, _
        3624381080#, 310598401, 607225278, 1426881987, 1925078388, 2162078206#, 2614888103#, 3248222580#, _
        3835390401#, 4022224774#, 264347078, 604807628, 770255983, 1249150122, 1555081692, 1996064986, _
        2554220882#, 2821834349#, 2952996808#, 3210313671#, 3336571891#, 3584528711#, 113926993, 338241895, _
        666307205, 773529912, 1294757372, 1396182291, 1695183700, 1986661051, 2177026350#, 2456956037#, _
        2730485921#, 2820302411#, 3259730800#, 3345764771#, 3516065817#, 3600352804#, 4094571909#, 275423344, _
        430227734, 506948616, 659060556, 883997877, 958139571, 1322822218, 1537002063, 1747873779, _
        1955562222, 2024104815, 2227730452#, 2361852424#, 2428436474#, 2756734187#, 3204031479#, 3329325298#)
 
    sMessage = Nz(sMessage, "")
    strLen = Len(sMessage) * 8
    sMessage = sMessage & Chr(128)
    done512 = False
    index512 = 0
    
    'Padding
    'If the length of the message mod 64 (The remainder after dividing by 64)
    'is less than 56 then do 56 - (the remainder of) the length of the message / 64
    'Add that number of chr(0)s for pading
    
    'If it's greater than 56 then do the same thing expect 120 instead of 56
    
    If (Len(sMessage) Mod 64) < 56 Then
        sMessage = sMessage & String(56 - (Len(sMessage) Mod 64), Chr(0))
    ElseIf (Len(sMessage) Mod 64) > 56 Then
        sMessage = sMessage & String(120 - (Len(sMessage) Mod 64), Chr(0))
    End If
    
    
    'The length of the message, after adding padding should be 60
    
    sMessage = sMessage & Chr(0) & Chr(0) & Chr(0) & Chr(0)
 
    sMessage = sMessage & Chr(Int((strLen / mask(0) - Int(strLen / mask(0))) * 256))
    sMessage = sMessage & Chr(Int((strLen / mask(1) - Int(strLen / mask(1))) * 256))
    sMessage = sMessage & Chr(Int((strLen / mask(2) - Int(strLen / mask(2))) * 256))
    sMessage = sMessage & Chr(Int((strLen / mask(3) - Int(strLen / mask(3))) * 256))
 
    Do Until done512
        For i = 0 To 15
            words(i) = Asc(Mid(sMessage, index512 * 64 + i * 4 + 1, 1)) * mask(1) + Asc(Mid(sMessage, index512 * 64 + i * 4 + 2, 1)) * mask(2) + Asc(Mid(sMessage, index512 * 64 + i * 4 + 3, 1)) * mask(3) + Asc(Mid(sMessage, index512 * 64 + i * 4 + 4, 1))
        Next
 
        For i = 16 To 63
            s0 = largeXor(largeXor(rightRotate(words(i - 15), 7, 32), rightRotate(words(i - 15), 18, 32), 32), Int(words(i - 15) / 8), 32)
            s1 = largeXor(largeXor(rightRotate(words(i - 2), 17, 32), rightRotate(words(i - 2), 19, 32), 32), Int(words(i - 2) / 1024), 32)
            words(i) = Mod32Bit(words(i - 16) + s0 + words(i - 7) + s1)
        Next
 
        For i = 0 To 7
            temp(i) = hashValues(i)
        Next
 
        For i = 0 To 63
            s0 = largeXor(largeXor(rightRotate(temp(0), 2, 32), rightRotate(temp(0), 13, 32), 32), rightRotate(temp(0), 22, 32), 32)
            maj = largeXor(largeXor(largeAnd(temp(0), temp(1), 32), largeAnd(temp(0), temp(2), 32), 32), largeAnd(temp(1), temp(2), 32), 32)
            t2 = Mod32Bit(s0 + maj)
            s1 = largeXor(largeXor(rightRotate(temp(4), 6, 32), rightRotate(temp(4), 11, 32), 32), rightRotate(temp(4), 25, 32), 32)
            ch = largeXor(largeAnd(temp(4), temp(5), 32), largeAnd(largeNot(temp(4), 32), temp(6), 32), 32)
            t1 = Mod32Bit(temp(7) + s1 + ch + fraccubeprimes(i) + words(i))
 
            temp(7) = temp(6)
            temp(6) = temp(5)
            temp(5) = temp(4)
            temp(4) = Mod32Bit(temp(3) + t1)
            temp(3) = temp(2)
            temp(2) = temp(1)
            temp(1) = temp(0)
            temp(0) = Mod32Bit(t1 + t2)
        Next
 
        For i = 0 To 7
            hashValues(i) = Mod32Bit(hashValues(i) + temp(i))
        Next
 
        If (index512 + 1) * 64 >= Len(sMessage) Then done512 = True
        index512 = index512 + 1
    Loop
 
    'this returns an array
'    For i = 0 To 31
'        result(i) = Int((hashValues(i \ 4) / mask(i Mod 4) - Int(hashValues(i \ 4) / mask(i Mod 4))) * 256)
'    Next
    
    'returns a hashed string
    For i = 0 To 31
        
        result = result & Right("00" & Hex(Int((hashValues(i \ 4) / mask(i Mod 4) - Int(hashValues(i \ 4) / mask(i Mod 4))) * 256)), 2)
    
    Next i
    
    SHA = result
    
End Function
 
Function Mod32Bit(value)
    Mod32Bit = Int((value / 4294967296# - Int(value / 4294967296#)) * 4294967296#)
End Function
 
Function rightRotate(value, amount, totalBits)
    'To leftRotate, make amount = totalBits - amount
    Dim i
    rightRotate = 0
 
    For i = 0 To (totalBits - 1)
        If i >= amount Then
            rightRotate = rightRotate + (Int((value / (2 ^ (i + 1)) - Int(value / (2 ^ (i + 1)))) * 2)) * 2 ^ (i - amount)
        Else
            rightRotate = rightRotate + (Int((value / (2 ^ (i + 1)) - Int(value / (2 ^ (i + 1)))) * 2)) * 2 ^ (totalBits - amount + i)
        End If
    Next
End Function
 
Function largeXor(value, xorValue, totalBits)
    Dim i, a, b
    largeXor = 0
 
    For i = 0 To (totalBits - 1)
        a = (Int((value / (2 ^ (i + 1)) - Int(value / (2 ^ (i + 1)))) * 2))
        b = (Int((xorValue / (2 ^ (i + 1)) - Int(xorValue / (2 ^ (i + 1)))) * 2))
        If a <> b Then
            largeXor = largeXor + 2 ^ i
        End If
    Next
End Function
 
Function largeNot(value, totalBits)
    Dim i, a
    largeNot = 0
 
    For i = 0 To (totalBits - 1)
        a = Int((value / (2 ^ (i + 1)) - Int(value / (2 ^ (i + 1)))) * 2)
        If a = 0 Then
            largeNot = largeNot + 2 ^ i
        End If
    Next
End Function
 
Function largeAnd(value, andValue, totalBits)
    Dim i, a, b
    largeAnd = 0
 
    For i = 0 To (totalBits - 1)
        a = Int((value / (2 ^ (i + 1)) - Int(value / (2 ^ (i + 1)))) * 2)
        b = (Int((andValue / (2 ^ (i + 1)) - Int(andValue / (2 ^ (i + 1)))) * 2))
        If a = 1 And b = 1 Then
            largeAnd = largeAnd + 2 ^ i
        End If
    Next
End Function


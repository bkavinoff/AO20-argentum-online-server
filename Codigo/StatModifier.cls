VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "StatModifier"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Implements IBaseEffectOverTime

Dim TickTime As Long
Dim TimeSinceLastTick As Long
Private DotInfo As t_BaseDotInfo
Private Source As t_AnyReference
Private PhysicalDamageReduction As Single
Private MagicDamageReduction As Single
Private PhysicalDamageDone As Single
Private MagicDamageDone As Single

Public Sub Setup(ByVal sourceIndex As Integer, ByVal sourceType As e_ReferenceType, ByVal TargetIndex As Integer, ByVal TargetType As e_ReferenceType, _
                 ByVal EffectId As Integer, ByVal ID As Integer)
    Call SetRef(DotInfo.TargetRef, TargetIndex, TargetType)
    Call SetRef(Source, sourceIndex, sourceType)
    Debug.Print "setting new id: " & ID & " to: " & DotInfo.UniqueId & " on target: " & TargetIndex
    DotInfo.UniqueId = ID
    DotInfo.RemoveEffect = False
    DotInfo.EotId = EffectId
    TimeSinceLastTick = 0
    With EffectOverTime(EffectId)
        TickTime = .TickTime
        PhysicalDamageReduction = .PhysicalDamageReduction
        MagicDamageReduction = .MagicDamageReduction
        PhysicalDamageDone = .PhysicalDamageDone
        MagicDamageDone = .MagicDamageDone
    End With
    If IsValidRef(DotInfo.TargetRef) Then
        If DotInfo.TargetRef.RefType = eUser Then
            Call IncreaseSingle(UserList(DotInfo.TargetRef.ArrayIndex).Modifiers.MagicDamageBonus, MagicDamageDone)
            Call IncreaseSingle(UserList(DotInfo.TargetRef.ArrayIndex).Modifiers.PhysicalDamageBonus, PhysicalDamageDone)
            Call IncreaseSingle(UserList(DotInfo.TargetRef.ArrayIndex).Modifiers.MagicDamageReduction, MagicDamageReduction)
            Call IncreaseSingle(UserList(DotInfo.TargetRef.ArrayIndex).Modifiers.PhysicalDamageReduction, PhysicalDamageReduction)
        End If
    End If
End Sub

Public Property Get IBaseEffectOverTime_TypeId() As Integer
    IBaseEffectOverTime_TypeId = e_EffectOverTimeType.eApplyModifiers
End Property

Public Property Get IBaseEffectOverTime_UniqueId() As Integer
    IBaseEffectOverTime_UniqueId = DotInfo.UniqueId
End Property

Public Property Get IBaseEffectOverTime_CasterIsValid() As Boolean
    IBaseEffectOverTime_CasterIsValid = IsValidRef(Source)
End Property

Public Property Get IBaseEffectOverTime_CasterArrayIndex() As Integer
    IBaseEffectOverTime_CasterArrayIndex = Source.ArrayIndex
End Property

Public Property Get IBaseEffectOverTime_CasterRefType() As e_ReferenceType
    IBaseEffectOverTime_CasterRefType = Source.RefType
End Property

Public Property Get IBaseEffectOverTime_CasterUserId() As Long
    IBaseEffectOverTime_CasterUserId = Source.userID
End Property

Public Property Get IBaseEffectOverTime_TargetIsValid() As Boolean
    IBaseEffectOverTime_TargetIsValid = IsValidRef(DotInfo.TargetRef)
End Property

Public Property Get IBaseEffectOverTime_TargetArrayIndex() As Integer
    IBaseEffectOverTime_TargetArrayIndex = DotInfo.TargetRef.ArrayIndex
End Property

Public Property Get IBaseEffectOverTime_TargetRefType() As e_ReferenceType
    IBaseEffectOverTime_TargetRefType = DotInfo.TargetRef.RefType
End Property

Public Property Get IBaseEffectOverTime_TargetUserId() As Long
    IBaseEffectOverTime_TargetUserId = DotInfo.TargetRef.userID
End Property

Public Property Get IBaseEffectOverTime_EffectType() As e_EffectType
    IBaseEffectOverTime_EffectType = EffectOverTime(DotInfo.EotId).BuffType
End Property

Public Sub IBaseEffectOverTime_Update(ByVal deltaTime As Long)
    TimeSinceLastTick = TimeSinceLastTick + deltaTime
    If TimeSinceLastTick >= TickTime Or Not IsValidRef(DotInfo.TargetRef) Then
        DotInfo.RemoveEffect = True
    End If
End Sub

Public Property Get IBaseEffectOverTime_RemoveMe() As Boolean
    IBaseEffectOverTime_RemoveMe = DotInfo.RemoveEffect
End Property

Public Property Let IBaseEffectOverTime_RemoveMe(ByVal value As Boolean)
    DotInfo.RemoveEffect = value
End Property

Public Sub IBaseEffectOverTime_Reset()
    TimeSinceLastTick = 0
End Sub

Public Property Get IBaseEffectOverTime_EotId() As Integer
    IBaseEffectOverTime_EotId = DotInfo.EotId
End Property

Public Sub IBaseEffectOverTime_OnRemove()
    Call IncreaseSingle(UserList(DotInfo.TargetRef.ArrayIndex).Modifiers.MagicDamageBonus, -MagicDamageDone)
    Call IncreaseSingle(UserList(DotInfo.TargetRef.ArrayIndex).Modifiers.PhysicalDamageBonus, -PhysicalDamageDone)
    Call IncreaseSingle(UserList(DotInfo.TargetRef.ArrayIndex).Modifiers.MagicDamageReduction, -MagicDamageReduction)
    Call IncreaseSingle(UserList(DotInfo.TargetRef.ArrayIndex).Modifiers.PhysicalDamageReduction, -PhysicalDamageReduction)
End Sub

Public Sub IBaseEffectOverTime_TargetUserMagic(ByVal MagicIndex As Integer)
End Sub

Public Sub IBaseEffectOverTime_TargetPerformAttack()
End Sub

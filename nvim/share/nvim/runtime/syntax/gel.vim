" Vim syntax file
" Language:	TI Code Composer Studio General Extension Language
" Document:	https://downloads.ti.com/ccs/esd/documents/users_guide/ccs_debug-gel.html
" Maintainer:	Wu, Zhenyu <wuzhenyu@ustc.edu>
" Last Change:	2024 Dec 25

if exists("b:current_syntax")
  finish
endif

runtime! syntax/cpp.vim

syn keyword gelStatement	StartUp GEL_AddInputFile GEL_AddOutputFile GEL_AdvancedReset GEL_AsmStepInto GEL_AsmStepOver GEL_BreakPtAdd GEL_BreakPtDel GEL_BreakPtDisable GEL_BreakPtReset GEL_CancelTimer GEL_Connect GEL_Dialog GEL_DisableFileOutput GEL_DisableRealtime GEL_Disconnect GEL_EnableClock GEL_EnableFileOutput GEL_EnableRealtime GEL_EnableZeroFill GEL_EvalOnTarget GEL_GetBoolDebugProperty GEL_GetBoolDriverProperty GEL_GetBoolTargetDbProperty GEL_GetNumericDebugProperty GEL_GetNumericDriverProperty GEL_GetNumericTargetDbProperty GEL_GetStringDebugProperty GEL_GetStringDriverProperty GEL_GetStringTargetDbProperty GEL_Go GEL_Halt GEL_HandleTargetError GEL_HWBreakPtAdd GEL_HWBreakPtDel GEL_HWBreakPtDisable GEL_HWBreakPtReset GEL_IsConnected GEL_IsHalted GEL_IsInRealtimeMode GEL_IsResetSupported GEL_IsTimerSet GEL_Load GEL_LoadBin GEL_LoadGel GEL_LoadProgramOnly GEL_MapAdd GEL_MapAddStr GEL_MapDelete GEL_MapOff GEL_MapOn GEL_MapReset GEL_MatchesConnection GEL_MemoryFill GEL_MemoryListSupportedTypes GEL_MemoryLoad GEL_MemoryLoadData GEL_MemorySave GEL_MemorySaveBin GEL_MemorySaveCoff GEL_MemorySaveData GEL_MemorySaveHex GEL_PatchAssembly GEL_ProbePtAdd GEL_ProbePtDel GEL_ProbePtDisable GEL_ProbePtReset GEL_ReConnect GEL_RefreshWindows GEL_Reload GEL_RemoveDebugState GEL_RemoveInputFile GEL_RemoveOutputFile GEL_Reset GEL_Restart GEL_RestoreDebugState GEL_Run GEL_RunF GEL_SetBlockResetMode GEL_SetBoolDebugProperty GEL_SetClockEvent GEL_SetNumericDebugProperty GEL_SetSemihostingMainArgs GEL_SetStringDebugProperty GEL_SetTimer GEL_SetWaitInResetMode GEL_SrcStepInto GEL_SrcStepOver GEL_StepInto GEL_StepOut GEL_StepOver GEL_StrCat GEL_StrLen GEL_SubStr GEL_SymbolAdd GEL_SymbolAddOffset GEL_SymbolAddRel GEL_SymbolDisable GEL_SymbolEnable GEL_SymbolHideSection GEL_SymbolLoad GEL_SymbolLoadOffset GEL_SymbolLoadRel GEL_SymbolRemove GEL_SymbolShowSection GEL_SyncHalt GEL_SyncRun GEL_SyncStepInto GEL_SyncStepOut GEL_SyncStepOver GEL_System GEL_TargetTextOut GEL_TextOut GEL_Trace GEL_UnloadAllGels GEL_UnloadAllSymbols GEL_UnloadGel GEL_VerifyBinProgram GEL_VerifyProgram OnChildRunning OnFileLoaded OnHalt OnPreFileLoaded OnPreReset OnPreTargetConnect OnReset OnResetDetected OnRestart OnTargetConnect
syn keyword gelModifier	hotmenu menuitem

hi def link gelStatement	Statement
hi def link gelModifier		Type

let b:current_syntax = "gel"

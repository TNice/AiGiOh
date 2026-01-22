-- codex_amendment.lua
-- Shared helper module for "Codex Authority" Amendment-as-Mode system (Field Spell resident).
-- Drop this somewhere your card scripts can `dofile` / `require` consistently.

-- Namespace
Codex = Codex or {}

----------------------------------------------------------------
-- CONFIG (safe to edit)
----------------------------------------------------------------
-- If you want a setcode for "Codex" cards (optional), set it here.
-- (Not required for the Amendment engine itself.)
Codex.SET_CODEX = Codex.SET_CODEX or 0x123

Codex.COUNTER_PRECEDENT = Codex.COUNTER_PRECEDENT or 0xC0D1
Codex.COUNTER_STATUTE   = Codex.COUNTER_STATUTE   or 0xC0D2

-- Card IDs (from your TOML)
Codex.ID_FRAMEWORK = 92000001 -- Codex Authority – Statutory Framework
Codex.ID_TRIBUNAL  = 92000032 -- Codex Supreme Tribunal – Final Authority

-- Custom event code for "Amendment activated/replaced"
-- (Pick a stable, unique number range; EVENT_CUSTOM + <unique> is standard.)
Codex.EVENT_AMEND_CHANGE = Codex.EVENT_AMEND_CHANGE or (EVENT_CUSTOM + 92000001)

-- If you want to validate Amendment IDs, set Codex.AMENDMENT_MAX (or a whitelist later).
-- For now we accept any id > 0.
Codex.AMENDMENT_MAX = Codex.AMENDMENT_MAX or 99

----------------------------------------------------------------
-- INTERNAL FLAG CODES (do not edit once scripts depend on them)
----------------------------------------------------------------
-- Slot storage (label = Amendment ID, 0 means empty)
Codex.FLAG_AMEND_SLOT_A = 92000001 + 0xA0
Codex.FLAG_AMEND_SLOT_B = 92000001 + 0xA1

-- Slot locks (label ignored; presence means locked)
Codex.FLAG_AMEND_LOCK_A = 92000001 + 0xA2
Codex.FLAG_AMEND_LOCK_B = 92000001 + 0xA3

-- Slot negation markers (presence means "Amendment effects in this slot are negated")
Codex.FLAG_AMEND_NEG_A  = 92000001 + 0xA4
Codex.FLAG_AMEND_NEG_B  = 92000001 + 0xA5

-- Duel-scoped flags
Codex.FLAG_AMEND_ACTIVE_TURN = 92000001 + 0xB0 -- per player, resets at End Phase
Codex.FLAG_AMEND_REPLACED_CHAIN = 92000001 + 0xB1 -- per player, resets at Chain end

----------------------------------------------------------------
-- SMALL UTILS
----------------------------------------------------------------
local function _clamp_slot(slot)
	-- slot: 1 = A, 2 = B
	return (slot == 2) and 2 or 1
end

local function _slot_flag(slotA, slotB, slot)
	return (slot == 2) and slotB or slotA
end

local function _reset_flag(c, code)
	-- Ensure single-instance flag semantics (avoid stacking labels)
	if c and c.ResetFlagEffect then c:ResetFlagEffect(code) end
end

local function _set_flag_label(c, code, label, reset)
	reset = reset or (RESET_EVENT + RESETS_STANDARD)
	_reset_flag(c, code)
	c:RegisterFlagEffect(code, reset, 0, 1, label)
end

local function _set_flag(c, code, reset)
	reset = reset or (RESET_EVENT + RESETS_STANDARD)
	_reset_flag(c, code)
	c:RegisterFlagEffect(code, reset, 0, 1)
end

local function _has_flag(c, code)
	return c and c:GetFlagEffect(code) > 0
end

----------------------------------------------------------------
-- FRAMEWORK FINDERS
----------------------------------------------------------------
function Codex.IsFramework(c)
	return c and c:IsFaceup() and c:IsCode(Codex.ID_FRAMEWORK) and c:IsLocation(LOCATION_FZONE)
end

function Codex.GetFramework(tp)
	-- Returns face-up Framework in Field Zone (or nil)
	return Duel.GetFieldCard(tp, LOCATION_FZONE, 0)
end

function Codex.RequireFramework(tp)
	local fs = Codex.GetFramework(tp)
	if Codex.IsFramework(fs) then return fs end
	return nil
end

----------------------------------------------------------------
-- TRIBUNAL CHECK (controls 2-slot allowance)
----------------------------------------------------------------
function Codex.HasTribunal(tp)
	return Duel.IsExistingMatchingCard(function(c)
		return c:IsFaceup() and c:IsCode(Codex.ID_TRIBUNAL)
	end, tp, LOCATION_MZONE, 0, 1, nil)
end

function Codex.GetMaxAmendSlots(tp)
	return Codex.HasTribunal(tp) and 2 or 1
end

function Codex.ClearSlotBIfNoTribunal(tp)
	-- Call this from Tribunal leave-field logic OR periodically from Framework if you want.
	local fs = Codex.RequireFramework(tp)
	if not fs then return end
	if not Codex.HasTribunal(tp) then
		Codex.SetAmendSlot(tp, 2, 0) -- clears slot B + associated flags
	end
end

----------------------------------------------------------------
-- SLOT GET/SET
----------------------------------------------------------------
function Codex.GetAmendSlot(fs, slot)
	slot = _clamp_slot(slot)
	local code = _slot_flag(Codex.FLAG_AMEND_SLOT_A, Codex.FLAG_AMEND_SLOT_B, slot)
	if not fs then return 0 end
	if fs:GetFlagEffect(code) == 0 then return 0 end
	local v = fs:GetFlagEffectLabel(code) or 0
	return v
end

function Codex.IsAmendSlotLocked(fs, slot)
	slot = _clamp_slot(slot)
	local code = _slot_flag(Codex.FLAG_AMEND_LOCK_A, Codex.FLAG_AMEND_LOCK_B, slot)
	return _has_flag(fs, code)
end

function Codex.IsAmendSlotNegated(fs, slot)
	slot = _clamp_slot(slot)
	local code = _slot_flag(Codex.FLAG_AMEND_NEG_A, Codex.FLAG_AMEND_NEG_B, slot)
	return _has_flag(fs, code)
end

function Codex.LockAmendSlot(fs, slot, reset)
	-- reset defaults to "until End Phase"
	reset = reset or (RESET_PHASE + PHASE_END)
	slot = _clamp_slot(slot)
	local code = _slot_flag(Codex.FLAG_AMEND_LOCK_A, Codex.FLAG_AMEND_LOCK_B, slot)
	_set_flag(fs, code, reset)
end

function Codex.NegateAmendSlot(fs, slot, reset)
	-- reset defaults to "until End Phase"
	reset = reset or (RESET_PHASE + PHASE_END)
	slot = _clamp_slot(slot)
	-- If slot is locked, this should fail deterministically.
	if Codex.IsAmendSlotLocked(fs, slot) then return false end
	local code = _slot_flag(Codex.FLAG_AMEND_NEG_A, Codex.FLAG_AMEND_NEG_B, slot)
	_set_flag(fs, code, reset)
	return true
end

function Codex.ClearNegateSlot(fs, slot)
	slot = _clamp_slot(slot)
	local code = _slot_flag(Codex.FLAG_AMEND_NEG_A, Codex.FLAG_AMEND_NEG_B, slot)
	_reset_flag(fs, code)
end

function Codex.SetAmendSlot(tp, slot, amend_id)
	-- amend_id: 0 clears slot; >0 sets/overwrites slot
	-- Clears lock/negation for the slot when the slot is cleared.
	local fs = Codex.RequireFramework(tp)
	if not fs then return false end

	slot = _clamp_slot(slot)
	if slot == 2 and Codex.GetMaxAmendSlots(tp) < 2 then
		-- cannot hold slot B without Tribunal; treat as clear request only
		amend_id = 0
	end

	if amend_id < 0 then amend_id = 0 end
	if amend_id > 0 and amend_id > Codex.AMENDMENT_MAX then
		-- If you later want strict validation, swap this to false.
		-- For now, clamp to allow future expansion.
	end

	local slot_code = _slot_flag(Codex.FLAG_AMEND_SLOT_A, Codex.FLAG_AMEND_SLOT_B, slot)
	if amend_id == 0 then
		_reset_flag(fs, slot_code)
		-- Also clear lock and negation for that slot
		_reset_flag(fs, _slot_flag(Codex.FLAG_AMEND_LOCK_A, Codex.FLAG_AMEND_LOCK_B, slot))
		_reset_flag(fs, _slot_flag(Codex.FLAG_AMEND_NEG_A,  Codex.FLAG_AMEND_NEG_B,  slot))
		return true
	end

	_set_flag_label(fs, slot_code, amend_id)
	-- mark "Amendment was active this turn"
	Duel.RegisterFlagEffect(tp, Codex.FLAG_AMEND_ACTIVE_TURN, RESET_PHASE + PHASE_END, 0, 1)
	return true
end

----------------------------------------------------------------
-- QUERIES
----------------------------------------------------------------
function Codex.HasAnyActiveAmendment(tp)
	local fs = Codex.RequireFramework(tp)
	if not fs then return false end
	return (Codex.GetAmendSlot(fs, 1) ~= 0) or (Codex.GetAmendSlot(fs, 2) ~= 0)
end

function Codex.GetActiveAmendments(tp)
	-- returns (a_id, b_id, count)
	local fs = Codex.RequireFramework(tp)
	if not fs then return 0, 0, 0 end
	local a = Codex.GetAmendSlot(fs, 1)
	local b = Codex.GetAmendSlot(fs, 2)
	local ct = 0
	if a ~= 0 then ct = ct + 1 end
	if b ~= 0 then ct = ct + 1 end
	return a, b, ct
end

function Codex.GetFirstEmptySlot(tp)
	local fs = Codex.RequireFramework(tp)
	if not fs then return nil end
	local maxs = Codex.GetMaxAmendSlots(tp)
	if Codex.GetAmendSlot(fs, 1) == 0 then return 1 end
	if maxs >= 2 and Codex.GetAmendSlot(fs, 2) == 0 then return 2 end
	return nil
end

function Codex.CanReplaceAnySlot(tp)
	local fs = Codex.RequireFramework(tp)
	if not fs then return false end
	local maxs = Codex.GetMaxAmendSlots(tp)
	-- Replace is possible if there exists an active, unlocked slot
	if Codex.GetAmendSlot(fs, 1) ~= 0 and not Codex.IsAmendSlotLocked(fs, 1) then return true end
	if maxs >= 2 and Codex.GetAmendSlot(fs, 2) ~= 0 and not Codex.IsAmendSlotLocked(fs, 2) then return true end
	return false
end

function Codex.WasAmendmentActiveThisTurn(tp)
	return Duel.GetFlagEffect(tp, Codex.FLAG_AMEND_ACTIVE_TURN) > 0
end

function Codex.WasAmendmentReplacedThisChain(tp)
	return Duel.GetFlagEffect(tp, Codex.FLAG_AMEND_REPLACED_CHAIN) > 0
end

----------------------------------------------------------------
-- EVENTS / OPERATIONS
----------------------------------------------------------------
function Codex.RaiseAmendChange(fs, e, tp, slot, new_id, is_replace)
	-- Custom event: use `ev` to carry new_id (and we encode slot/replace in reason if needed later)
	-- We also set the "active this turn" flag here redundantly for safety.
	Duel.RegisterFlagEffect(tp, Codex.FLAG_AMEND_ACTIVE_TURN, RESET_PHASE + PHASE_END, 0, 1)
	-- If it's a replacement, set chain-gate flag
	if is_replace then
		Duel.RegisterFlagEffect(tp, Codex.FLAG_AMEND_REPLACED_CHAIN, RESET_CHAIN, 0, 1)
	end
	-- Raise event: `ev` is new_id, `rp` is tp
	Duel.RaiseEvent(fs, Codex.EVENT_AMEND_CHANGE, e, 0, tp, slot, new_id)
end

function Codex.ActivateAmendment(tp, e, new_id)
	-- Activates a new Amendment into an empty slot if possible; otherwise requires replace.
	local fs = Codex.RequireFramework(tp)
	if not fs then return false end

	local slot = Codex.GetFirstEmptySlot(tp)
	if not slot then return false end

	if not Codex.SetAmendSlot(tp, slot, new_id) then return false end
	Codex.RaiseAmendChange(fs, e, tp, slot, new_id, false)
	return true
end

function Codex.ReplaceAmendment(tp, e, slot, new_id)
	-- Replace 1 active Amendment with a different one (slot chosen by caller/selector).
	local fs = Codex.RequireFramework(tp)
	if not fs then return false end

	slot = _clamp_slot(slot)
	if slot == 2 and Codex.GetMaxAmendSlots(tp) < 2 then return false end
	if Codex.IsAmendSlotLocked(fs, slot) then return false end

	local cur = Codex.GetAmendSlot(fs, slot)
	if cur == 0 then return false end
	if cur == new_id then return false end -- "different one"

	if not Codex.SetAmendSlot(tp, slot, new_id) then return false end
	Codex.RaiseAmendChange(fs, e, tp, slot, new_id, true)
	return true
end

function Codex.ActivateOrReplaceAmendment(tp, e, new_id, preferred_replace_slot)
	-- Convenience: if empty slot exists -> activate; else replace preferred slot (or first legal).
	local fs = Codex.RequireFramework(tp)
	if not fs then return false end

	local slot = Codex.GetFirstEmptySlot(tp)
	if slot then
		return Codex.ActivateAmendment(tp, e, new_id)
	end

	-- No empty slot: replace
	local maxs = Codex.GetMaxAmendSlots(tp)

	-- Try preferred slot first
	if preferred_replace_slot then
		local s = _clamp_slot(preferred_replace_slot)
		if s == 2 and maxs < 2 then s = 1 end
		if Codex.ReplaceAmendment(tp, e, s, new_id) then return true end
	end

	-- Otherwise replace first legal slot
	if Codex.GetAmendSlot(fs, 1) ~= 0 and not Codex.IsAmendSlotLocked(fs, 1) then
		if Codex.ReplaceAmendment(tp, e, 1, new_id) then return true end
	end
	if maxs >= 2 and Codex.GetAmendSlot(fs, 2) ~= 0 and not Codex.IsAmendSlotLocked(fs, 2) then
		if Codex.ReplaceAmendment(tp, e, 2, new_id) then return true end
	end

	return false
end

----------------------------------------------------------------
-- AMENDMENT EFFECT GUARDS (to be used when you implement amendment effects)
----------------------------------------------------------------
function Codex.ShouldApplyAmendment(fs, slot)
	-- Returns true if slot has an Amendment and it is not negated.
	if not fs then return false end
	slot = _clamp_slot(slot)
	if Codex.GetAmendSlot(fs, slot) == 0 then return false end
	if Codex.IsAmendSlotNegated(fs, slot) then return false end
	return true
end

function Codex.GetAmendmentId(fs, slot)
	slot = _clamp_slot(slot)
	return Codex.GetAmendSlot(fs, slot)
end

function Codex.UpdateFrameworkHint(tp)
	local fs=Codex.RequireFramework(tp)
	if not fs then return end

	local a=Codex.GetAmendSlot(fs,1)
	local b=Codex.GetAmendSlot(fs,2)
	local maxs=Codex.GetMaxAmendSlots(tp)

	-- Persistent numeric indicator on the card
	if maxs>=2 then
		fs:SetHint(CHINT_NUMBER, (a or 0)*100 + (b or 0))
	else
		fs:SetHint(CHINT_NUMBER, a or 0)
	end

	-- Transient clarity message (only when 2 Amendments exist)
	if maxs>=2 and a~=0 and b~=0 then
		Duel.Hint(HINT_MESSAGE, tp, "Active Amendments: "..a..","..b)
	end
end
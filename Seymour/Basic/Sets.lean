import Mathlib.Data.Set.SymmDiff
import Mathlib.Order.CompletePartialOrder
import Mathlib.Order.Disjoint
import Mathlib.Order.SymmDiff
import Mathlib.Tactic

import Seymour.Basic.Basic

/-!
This provides lemmas about sets (mostly dealing with disjointness) that are missing in Mathlib.
-/

variable {α : Type}

section Other

lemma set_union_union_eq_rev (X Y Z : Set α) : X ∪ Y ∪ Z = Z ∪ Y ∪ X := by
  rw [Set.union_assoc, Set.union_comm, Set.union_comm Y Z]

lemma wo_inter_union_eq_union {X Y : Set α} : X \ (X ∩ Y) ∪ Y = X ∪ Y := by
  tauto_set

lemma nonempty_inter_not_ssubset_empty_inter {A B E : Set α} (hA : (A ∩ E).Nonempty) (hB : B ∩ E = ∅) :
    ¬(A ⊂ B) := by
  intro ⟨hAB, _⟩
  obtain ⟨x, hxAE⟩ := hA
  have hxBE : x ∈ B ∩ E := (Set.inter_subset_inter hAB fun _ => id) hxAE
  rw [hB] at hxBE
  tauto

lemma in_of_in_union_of_ni_left {a : α} {X Y : Set α} (ha : a ∈ X ∪ Y) (haX : a ∉ X) : a ∈ Y := by
  cases ha with
  | inl hX => exact (haX hX).elim
  | inr hY => exact hY

lemma in_of_in_union_of_ni_right {a : α} {X Y : Set α} (ha : a ∈ X ∪ Y) (haY : a ∉ Y) : a ∈ X :=
  in_of_in_union_of_ni_left (Set.union_comm X Y ▸ ha) haY

lemma ssubset_self_union_other_elem {a : α} {X : Set α} (ha : a ∉ X) :
    X ⊂ X ∪ {a} := by
  refine ⟨Set.subset_union_left, ?_⟩
  rw [Set.union_subset_iff]
  tauto

lemma singleton_union_ssubset_union_iff {a : α} {A B : Set α} (haA : a ∉ A) (haB : a ∉ B) :
    A ∪ {a} ⊂ B ∪ {a} ↔ A ⊂ B := by
  constructor <;> intro ⟨hAB, hBA⟩ <;> constructor <;> simp_all

lemma ssubset_parts_ssubset {A B E₁ E₂ : Set α}
    (hA : A ⊆ E₁ ∪ E₂) (hB : B ⊆ E₁ ∪ E₂) (hAB₁ : A ∩ E₁ ⊂ B ∩ E₁) (hAB₂ : A ∩ E₂ ⊂ B ∩ E₂) :
    A ⊂ B := by
  constructor
  · obtain ⟨hE₁, _⟩ := hAB₁
    obtain ⟨hE₂, _⟩ := hAB₂
    rw [Set.left_eq_inter.← hA, Set.left_eq_inter.← hB, Set.inter_union_distrib_left, Set.inter_union_distrib_left]
    exact Set.union_subset_union hE₁ hE₂
  · intro hBA
    obtain ⟨_, hE₁⟩ := hAB₁
    obtain ⟨x, hxBE₁, hxnAE₁⟩ := Set.not_subset.→ hE₁
    have hxB : x ∈ B := Set.mem_of_mem_inter_left hxBE₁
    have hxE₁ : x ∈ E₁ := Set.mem_of_mem_inter_right hxBE₁
    tauto

lemma HasSubset.Subset.parts_eq {A E₁ E₂ : Set α} (hA : A ⊆ E₁ ∪ E₂) : (A ∩ E₁) ∪ (A ∩ E₂) = A :=
  ((subset_of_subset_of_eq
    (Set.subset_inter (fun _ => id) hA)
    (Set.inter_union_distrib_left A E₁ E₂)).antisymm
  (Set.union_subset Set.inter_subset_left Set.inter_subset_left)).symm

lemma elem_ni_wo_singleton (a : α) (X : Set α) : a ∉ X \ {a} :=
  Set.not_mem_diff_of_mem rfl

lemma subset_of_subset_diff {A B C : Set α} (hA : A ⊆ B \ C) : A ⊆ B :=
  fun _ hA' => Set.diff_subset (hA hA')

lemma singleton_inter_in_left {X Y : Set α} {a : α} (ha : X ∩ Y = {a}) : a ∈ X :=
  Set.mem_of_mem_inter_left (ha.symm.subset rfl)

lemma singleton_inter_in_right {X Y : Set α} {a : α} (ha : X ∩ Y = {a}) : a ∈ Y :=
  Set.mem_of_mem_inter_right (ha.symm.subset rfl)

lemma singleton_inter_subset_left {X Y : Set α} {a : α} (ha : X ∩ Y = {a}) : {a} ⊆ X := by
  rw [Set.singleton_subset_iff]
  exact singleton_inter_in_left ha

lemma singleton_inter_subset_right {X Y : Set α} {a : α} (ha : X ∩ Y = {a}) : {a} ⊆ Y := by
  rw [Set.singleton_subset_iff]
  exact singleton_inter_in_right ha

/-- Being a subset is preserved under subtracting sets. -/
lemma diff_subset_parent {X₁ X₂ E : Set α} (hXE : X₁ ⊆ E) :
    X₁ \ X₂ ⊆ E :=
  Set.diff_subset_iff.← (Set.subset_union_of_subset_right hXE X₂)

/-- Being a subset is preserved under taking intersections. -/
lemma inter_subset_left {X₁ X₂ E : Set α} (hXE : X₁ ⊆ E) :
    X₁ ∩ X₂ ⊆ E :=
  (Set.inter_subset_inter_left X₂ hXE).trans Set.inter_subset_left

/-- Being a subset is preserved under taking intersections. -/
lemma inter_subset_right {X₁ X₂ E : Set α} (hXE : X₂ ⊆ E) :
    X₁ ∩ X₂ ⊆ E := by
  rw [Set.inter_comm]
  exact inter_subset_left hXE

/-- Intersection of two sets is subset of their union. -/
lemma inter_subset_union {X₁ X₂ : Set α} :
    X₁ ∩ X₂ ⊆ X₁ ∪ X₂ :=
  inter_subset_left Set.subset_union_left

lemma eq_of_subset_of_diff_empty {A B : Set α} (hAB : A ⊆ B) (hBA : B \ A = ∅) : A = B :=
  A.union_empty ▸ hBA ▸ Set.union_diff_cancel hAB

end Other


section Disjoint

lemma Disjoint.ni_of_in {X Y : Set α} {a : α} (hXY : X ⫗ Y) (ha : a ∈ X) :
    a ∉ Y := by
  intro ha'
  simpa [hXY.inter_eq] using Set.mem_inter ha ha'

lemma disjoint_of_inter_left_wo {X Y Z : Set α} (hXY : X ∩ Y = Z) :
    X \ Z ⫗ Y := by
  tauto_set

lemma disjoint_of_inter_right_wo {X Y Z : Set α} (hXY : X ∩ Y = Z) :
    X ⫗ Y \ Z := by
  rw [disjoint_comm]
  rw [Set.inter_comm] at hXY
  exact disjoint_of_inter_left_wo hXY

lemma disjoint_of_singleton_inter_left_wo {X Y : Set α} {a : α} (hXY : X ∩ Y = {a}) :
    X \ {a} ⫗ Y :=
  disjoint_of_inter_left_wo hXY

lemma disjoint_of_singleton_inter_right_wo {X Y : Set α} {a : α} (hXY : X ∩ Y = {a}) :
    X ⫗ Y \ {a} :=
  disjoint_of_inter_right_wo hXY

lemma disjoint_of_singleton_inter_both_wo {X Y : Set α} {a : α} (hXY : X ∩ Y = {a}) :
    X \ {a} ⫗ Y \ {a} :=
  Disjoint.disjoint_sdiff_left (disjoint_of_singleton_inter_right_wo hXY)

lemma ni_of_in_wo_of_inter_left {X Y Z : Set α} (hXY : X ∩ Y = Z) {a : α} (ha : a ∈ X \ Z) :
    a ∉ Y :=
  (disjoint_of_inter_left_wo hXY).ni_of_in ha

lemma ni_of_in_wo_of_inter_right {X Y Z : Set α} (hXY : X ∩ Y = Z) {a : α} (ha : a ∈ Y \ Z) :
    a ∉ X :=
  (disjoint_of_inter_right_wo hXY).symm.ni_of_in ha

lemma disjoint_of_singleton_inter_subset_left {X Y Z : Set α} {a : α} (hXY : X ∩ Y = {a}) (hZ : Z ⊆ X) (haZ : a ∉ Z) :
    Z ⫗ Y := by
  have hY : (Y \ {a}) ∪ {a} = Y := (Set.diff_union_of_subset (singleton_inter_subset_right hXY))
  rw [←hY, Set.disjoint_union_right]
  constructor
  · exact Set.disjoint_of_subset_left hZ (disjoint_of_singleton_inter_right_wo hXY)
  · exact Set.disjoint_singleton_right.← haZ

lemma disjoint_of_singleton_inter_subset_right {X Y Z : Set α} {a : α} (hXY : X ∩ Y = {a}) (hZ : Z ⊆ Y) (haZ : a ∉ Z) :
    X ⫗ Z := by
  rw [Set.inter_comm] at hXY
  rw [disjoint_comm]
  exact disjoint_of_singleton_inter_subset_left hXY hZ haZ

lemma disjoint_nonempty_not_subset {A B : Set α} (hAB : A ⫗ B) (hA : A.Nonempty) :
    ¬(A ⊆ B) := by
  intro contr
  simp [Disjoint.eq_bot_of_le hAB, contr] at hA

lemma disjoint_nonempty_not_ssubset {A B : Set α} (hAB : A ⫗ B) (hA : A.Nonempty) :
    ¬(A ⊂ B) := by
  apply disjoint_nonempty_not_subset hAB at hA
  intro ⟨_, _⟩
  tauto

lemma ssubset_union_disjoint_nonempty {X Y : Set α} (hXY : X ⫗ Y) (hY : Y.Nonempty) :
    X ⊂ X ∪ Y := by
  constructor
  · exact Set.subset_union_left
  · by_contra hX
    apply Set.diff_subset_diff_left at hX
    rw [Set.union_diff_cancel_left (Set.disjoint_iff.→ hXY), Set.diff_self] at hX
    exact Set.not_nonempty_empty (Set.eq_empty_of_subset_empty hX ▸ hY)

lemma union_ssubset_union_iff {A B X : Set α} (hAX : A ⫗ X) (hBX : B ⫗ X) :
    A ∪ X ⊂ B ∪ X ↔ A ⊂ B := by
  constructor
  · intro hAB
    rw [Set.ssubset_iff_subset_ne] at hAB ⊢
    constructor
    · have hXX : X ⊆ X := Set.Subset.rfl
      have hAXXBXX := Set.diff_subset_diff hAB.left hXX
      rwa [Set.union_diff_cancel_right, Set.union_diff_cancel_right] at hAXXBXX
      · rwa [Set.disjoint_iff] at hBX
      · rwa [Set.disjoint_iff] at hAX
    · intro
      simp_all
  · intro hAB
    have hAB' : A ⊆ B := hAB.subset
    rw [Set.ssubset_iff_of_subset hAB'] at hAB
    obtain ⟨x, hx⟩ := hAB
    rw [Set.ssubset_iff_of_subset (Set.union_subset_union_left X hAB')]
    refine ⟨x, Set.mem_union_left X hx.left, fun hx' => ?_⟩
    rw [Set.mem_union] at hx'
    cases hx' with
    | inl hA => exact hx.right hA
    | inr hX => exact hBX.ni_of_in hx.left hX

lemma union_subset_union_iff {A B X : Set α} (hAX : A ⫗ X) (hBX : B ⫗ X) :
    A ∪ X ⊆ B ∪ X ↔ A ⊆ B := by
  constructor
  · intro hABX
    have hXX : (A ∪ X) \ X ⊆ (B ∪ X) \ X := Set.diff_subset_diff_left hABX
    have hXA : (A ∪ X) \ X = A := Set.union_diff_cancel_right (Set.disjoint_iff.→ hAX)
    have hXB : (B ∪ X) \ X = B := Set.union_diff_cancel_right (Set.disjoint_iff.→ hBX)
    rwa [hXA, hXB] at hXX
  · exact Set.union_subset_union_left X

lemma ssubset_disjoint_union_nonempty {X₁ X₂ : Set α} (hXX : X₁ ⫗ X₂) (hX₂ : X₂.Nonempty) :
    X₁ ⊂ X₁ ∪ X₂ := by
  rw [Set.ssubset_iff_of_subset Set.subset_union_left]
  obtain ⟨x, hx⟩ := hX₂
  exact ⟨x, Set.mem_union_right X₁ hx, Disjoint.ni_of_in hXX.symm hx⟩

lemma ssubset_disjoint_nonempty_union {X₁ X₂ : Set α} (hXX : X₁ ⫗ X₂) (hX₁ : X₁.Nonempty) :
    X₂ ⊂ X₁ ∪ X₂ := by
  rw [disjoint_comm] at hXX
  rw [Set.union_comm]
  exact ssubset_disjoint_union_nonempty hXX hX₁

/-- If two sets are disjoint, then any set is disjoint with their intersection -/
lemma disjoint_inter_disjoint {A B : Set α} (C : Set α) (hAB : A ⫗ B) : C ⫗ A ∩ B := by
  rw [hAB.inter_eq]
  exact Set.disjoint_empty C

lemma diff_inter_disjoint_diff_inter (X₁ X₂ : Set α) :
    X₁ \ (X₁ ∩ X₂) ⫗ X₂ \ (X₁ ∩ X₂) := by
  rw [Set.diff_self_inter, Set.diff_inter_self_eq_diff]
  exact disjoint_sdiff_sdiff

lemma right_eq_right_of_union_eq_union {A₁ A₂ B₁ B₂ : Set α}
    (hA : A₁ = A₂) (hB₁ : A₁ ⫗ B₁) (hB₂ : A₂ ⫗ B₂) (hAB : A₁ ∪ B₁ = A₂ ∪ B₂) :
    B₁ = B₂ := by
  tauto_set

end Disjoint


section symmDiff

/-- Symmetric difference of two sets is their union minus their intersection. -/
lemma symmDiff_eq_alt (X Y : Set α) : symmDiff X Y = (X ∪ Y) \ (X ∩ Y) := by
  tauto_set

/-- Symmetric difference of two sets is disjoint with their intersection. -/
lemma symmDiff_disjoint_inter (X Y : Set α) : symmDiff X Y ⫗ X ∩ Y := by
  rw [symmDiff_eq_alt]
  exact Set.disjoint_sdiff_left

lemma symmDiff_empty_eq (X : Set α) : symmDiff X ∅ = X := by
  rw [symmDiff_eq_alt, Set.union_empty, Set.inter_empty, Set.diff_empty]

lemma empty_symmDiff_eq (X : Set α) : symmDiff ∅ X = X := by
  rw [symmDiff_eq_alt, Set.empty_union, Set.empty_inter, Set.diff_empty]

lemma symmDiff_subset_ground_right {X Y E : Set α} (hE : symmDiff X Y ⊆ E) (hX : X ⊆ E) : Y ⊆ E := by
  rw [symmDiff_eq_alt, Set.diff_subset_iff, Set.union_eq_self_of_subset_left (inter_subset_left hX),
    Set.union_subset_iff] at hE
  exact hE.right

lemma symmDiff_subset_ground_left {X Y E : Set α} (hE : symmDiff X Y ⊆ E) (hX : Y ⊆ E) : X ⊆ E :=
  symmDiff_subset_ground_right (symmDiff_comm X Y ▸ hE) hX

end symmDiff

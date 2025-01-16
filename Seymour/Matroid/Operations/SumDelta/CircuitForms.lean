import Seymour.Matroid.Operations.SumDelta.Basic
import Seymour.ForMathlib.SetTheory


variable {α : Type}


section Basic

/-- Nonempty union of disjoint circuits of `M₁` satisfies circuit form of `M₁ Δ M₂`  -/
lemma BinaryMatroid.DeltaSum.CircuitForm_left {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hC : C.Nonempty) (hCE : C ⊆ BinaryMatroid.DeltaSum.E M₁ M₂) (hCM₁ : M₁.toMatroid.IsUnionDisjointCircuits C) :
    BinaryMatroid.DeltaSum.CircuitForm M₁ M₂ C :=
  ⟨hC, hCE, C, ∅, by simp, hCM₁, M₂.toMatroid.emptyUnionDisjointCircuits⟩

/-- Nonempty union of disjoint circuits of `M₂` satisfies circuit form of `M₁ Δ M₂`  -/
lemma BinaryMatroid.DeltaSum.CircuitForm_right {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hC : C.Nonempty) (hCE : C ⊆ BinaryMatroid.DeltaSum.E M₁ M₂) (hCM₂ : M₂.toMatroid.IsUnionDisjointCircuits C) :
    BinaryMatroid.DeltaSum.CircuitForm M₁ M₂ C :=
  ⟨hC, hCE, ∅, C, by simp, M₁.toMatroid.emptyUnionDisjointCircuits, hCM₂⟩

end Basic


section CircuitForm1

/-- Form 1 of circuits in `M₁ Δ M₂`: circuits of `M₁` that are disjoint with `M₁.E ∩ M₂.E` -/
def BinaryMatroid.DeltaSum.CircuitForm1 (M₁ M₂ : BinaryMatroid α) (C : Set α) : Prop :=
  M₁.toMatroid.Circuit C ∧ C ⫗ M₁.E ∩ M₂.E

/-- Circuit of form 1 is a circuit in `M₁` -/
lemma BinaryMatroid.DeltaSum.CircuitForm1.circuit_M₁ {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm1 M₁ M₂ C) :
    M₁.toMatroid.Circuit C :=
  hC.left

/-- Circuit of form 1 is disjoint with `M₁.E ∩ M₂.E` -/
lemma BinaryMatroid.DeltaSum.CircuitForm1.disjoint_inter {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm1 M₁ M₂ C) :
    C ⫗ M₁.E ∩ M₂.E :=
  hC.right

/-- Circuit of form 1 lies in `M₁.E ∪ M₂.E` -/
lemma BinaryMatroid.DeltaSum.CircuitForm1.subset_union {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm1 M₁ M₂ C) :
    C ⊆ M₁.E ∪ M₂.E :=
  Set.subset_union_of_subset_left hC.circuit_M₁.subset_ground M₂.E

/-- Circuit of form 1 lies in ground set of `M₁ Δ M₂` -/
lemma BinaryMatroid.DeltaSum.CircuitForm1.subset_ground {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm1 M₁ M₂ C) :
    C ⊆ BinaryMatroid.DeltaSum.E M₁ M₂ :=
  Set.subset_diff.← ⟨hC.subset_union, hC.disjoint_inter⟩

/-- Circuit of form 1 lies in `M₁.E \ (M₁.E ∩ M₂.E)` -/
lemma BinaryMatroid.DeltaSum.CircuitForm1.subset_M₁_diff_inter {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm1 M₁ M₂ C) :
    C ⊆ M₁.E \ (M₁.E ∩ M₂.E) :=
  Set.subset_diff.← ⟨hC.circuit_M₁.subset_ground, hC.disjoint_inter⟩

/-- Circuit of form 1 is disjoint with `M₂.E` -/
lemma BinaryMatroid.DeltaSum.CircuitForm1.disjoint_M₂ {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm1 M₁ M₂ C) :
    C ⫗ M₂.E := by
  have hMM := BinaryMatroid.DeltaSum.disjoint_grounds_diff_inter M₁ M₂
  have hCM₂ := Set.disjoint_of_subset_left hC.subset_M₁_diff_inter hMM
  have hCM₂ := Set.disjoint_union_right.← ⟨hCM₂, hC.disjoint_inter⟩
  rw [Set.diff_union_of_subset Set.inter_subset_right] at hCM₂
  exact hCM₂

/-- Circuit of form 1 satisfies circuit form of `M₁ Δ M₂` -/
lemma BinaryMatroid.DeltaSum.CircuitForm1.circuit_form {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm1 M₁ M₂ C) :
    BinaryMatroid.DeltaSum.CircuitForm M₁ M₂ C :=
  BinaryMatroid.DeltaSum.CircuitForm_left hC.circuit_M₁.nonempty hC.subset_ground hC.circuit_M₁.isUnionDisjointCircuits

/-- If `C` satisfies circuit predicate and is a union of disjoint circuits of `M₁`, then `C` is a circuit of `M₁` -/
lemma BinaryMatroid.DeltaSum.CircuitPred_udc_M₁ {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hCpred : BinaryMatroid.DeltaSum.CircuitPred M₁ M₂ C) (hCudc : M₁.toMatroid.IsUnionDisjointCircuits C) :
    M₁.toMatroid.Circuit C :=
  have ⟨⟨hC, hCE, _⟩, hCmin⟩ := hCpred
  ⟨hCudc.nonempty_dep hC, fun D hD hDC =>
    have ⟨_, D', hD', hDD'⟩ := M₁.toMatroid.dep_iff_has_circuit.→ hD
    (hCmin
        (BinaryMatroid.DeltaSum.CircuitForm1.circuit_form ⟨hD', (Set.subset_diff.→ ((hDD'.trans hDC).trans hCE)).right⟩)
        (hDD'.trans hDC)
      ).trans hDD'⟩

end CircuitForm1


section CircuitForm2

/-- Form 2 of circuits in `M₁ Δ M₂`: circuits of `M₂` that are disjoint with `M₁.E ∩ M₂.E` -/
def BinaryMatroid.DeltaSum.CircuitForm2 (M₁ M₂ : BinaryMatroid α) (C : Set α) : Prop :=
  M₂.toMatroid.Circuit C ∧ C ⫗ M₁.E ∩ M₂.E

/-- Circuit of form 2 is a circuit in `M₁` -/
lemma BinaryMatroid.DeltaSum.CircuitForm2.circuit_M₂ {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm2 M₁ M₂ C) :
    M₂.toMatroid.Circuit C :=
  hC.left

/-- Circuit of form 2 is disjoint with `M₁.E ∩ M₂.E` -/
lemma BinaryMatroid.DeltaSum.CircuitForm2.disjoint_inter {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm2 M₁ M₂ C) :
    C ⫗ M₁.E ∩ M₂.E :=
  hC.right

/-- Circuit of form 2 lies in `M₁.E ∪ M₂.E` -/
lemma BinaryMatroid.DeltaSum.CircuitForm2.subset_union {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm2 M₁ M₂ C) :
    C ⊆ M₁.E ∪ M₂.E :=
  Set.subset_union_of_subset_right hC.circuit_M₂.subset_ground M₁.E

/-- Circuit of form 2 lies in ground set of `M₁ Δ M₂` -/
lemma BinaryMatroid.DeltaSum.CircuitForm2.subset_ground {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm2 M₁ M₂ C) :
    C ⊆ BinaryMatroid.DeltaSum.E M₁ M₂ :=
  Set.subset_diff.← ⟨hC.subset_union, hC.disjoint_inter⟩

/-- Circuit of form 2 lies in `M₁.E \ (M₁.E ∩ M₂.E)` -/
lemma BinaryMatroid.DeltaSum.CircuitForm2.subset_M₂_diff_inter {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm2 M₁ M₂ C) :
    C ⊆ M₂.E \ (M₁.E ∩ M₂.E) :=
  Set.subset_diff.← ⟨hC.circuit_M₂.subset_ground, hC.disjoint_inter⟩

/-- Circuit of form 2 is disjoint with `M₂.E` -/
lemma BinaryMatroid.DeltaSum.CircuitForm2.disjoint_M₁ {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm2 M₁ M₂ C) :
    C ⫗ M₁.E := by
  have hMM := BinaryMatroid.DeltaSum.disjoint_grounds_diff_inter M₁ M₂
  have hCM₂ := Set.disjoint_of_subset_right hC.subset_M₂_diff_inter hMM
  have hCM₂ := Set.disjoint_union_right.← ⟨hCM₂.symm, hC.disjoint_inter⟩
  rw [Set.diff_union_of_subset Set.inter_subset_left] at hCM₂
  exact hCM₂

/-- Circuit of form 2 satisfies circuit form of `M₁ Δ M₂` -/
lemma BinaryMatroid.DeltaSum.CircuitForm2.circuit_form {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm2 M₁ M₂ C) : BinaryMatroid.DeltaSum.CircuitForm M₁ M₂ C :=
  BinaryMatroid.DeltaSum.CircuitForm_right hC.circuit_M₂.nonempty hC.subset_ground hC.circuit_M₂.isUnionDisjointCircuits

/-- If `C` satisfies circuit predicate and is a union of disjoint circuits of `M₂`, then `C` is a circuit of `M₂` -/
lemma BinaryMatroid.DeltaSum.CircuitPred_udc_M₂ {M₁ M₂ : BinaryMatroid α} {C : Set α}
    (hCpred : BinaryMatroid.DeltaSum.CircuitPred M₁ M₂ C) (hCudc : M₂.toMatroid.IsUnionDisjointCircuits C) :
    M₂.toMatroid.Circuit C :=
  have ⟨⟨hCnempty, hCE, _⟩, hCmin⟩ := hCpred
  ⟨hCudc.nonempty_dep hCnempty, fun D hD hDC =>
    have ⟨_, D', hD', hDD'⟩ := M₂.toMatroid.dep_iff_has_circuit.→ hD
    (hCmin
        (BinaryMatroid.DeltaSum.CircuitForm2.circuit_form ⟨hD', (Set.subset_diff.→ ((hDD'.trans hDC).trans hCE)).right⟩)
        (hDD'.trans hDC)
      ).trans hDD'⟩

end CircuitForm2


section CircuitForm3

/-- Form 3 of circuits in `M₁ Δ M₂`:
    sets `C₁ Δ C₂` where `C₁` and `C₂` are circuits in `M₁` and M₂`, respectively,
    with `C₁ ∩ (M₁.E ∩ M₂.E)` and `C₂ ∩ (M₁.E ∩ M₂.E)` being the same one-element set.
    Here we use equivalent definition by denoting `p` the single element in `C₁ ∩ C₂` and
    expressing `C₁` and `C₂` via `p`, `C`, and ground sets of `M₁` and `M₂`. -/
def BinaryMatroid.DeltaSum.CircuitForm3 (M₁ M₂ : BinaryMatroid α) (C : Set α) (p : α) : Prop :=
  M₁.toMatroid.Circuit ((C ∩ M₁.E) ∪ {p}) ∧
  M₂.toMatroid.Circuit ((C ∩ M₂.E) ∪ {p}) ∧
  C ⊆ BinaryMatroid.DeltaSum.E M₁ M₂

/-- Existential version of form 3 of circuits -/
def BinaryMatroid.DeltaSum.CircuitForm3.exists (M₁ M₂ : BinaryMatroid α) (C : Set α) : Prop :=
  ∃ p ∈ M₁.E ∩ M₂.E, BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p

variable {C : Set α} {p : α}

/-- Circuit of form 3 yields a circuit in `M₁` after intersecting it with `M₁.E` and adding `p` -/
def BinaryMatroid.DeltaSum.CircuitForm3.to_circuit_M₁ {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    M₁.toMatroid.Circuit ((C ∩ M₁.E) ∪ {p}) :=
  hC.left

/-- Circuit of form 3 yields a circuit in `M₂` after intersecting it with `M₁.E` and adding `p` -/
def BinaryMatroid.DeltaSum.CircuitForm3.to_circuit_M₂ {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    M₂.toMatroid.Circuit ((C ∩ M₂.E) ∪ {p}) :=
  hC.right.left

/-- Circuit of form 3 is subset of ground set of `M₁ Δ M₂` -/
def BinaryMatroid.DeltaSum.CircuitForm3.subset_ground {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    C ⊆ BinaryMatroid.DeltaSum.E M₁ M₂ :=
  hC.right.right

/-- Singleton element in definition of circuit form 3 lies in `M₁.E` -/
lemma BinaryMatroid.DeltaSum.CircuitForm3.singleton_subset_M₁ {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    {p} ⊆ M₁.E :=
  (Set.union_subset_iff.→ hC.to_circuit_M₁.subset_ground).right

/-- Singleton element in definition of circuit form 3 lies in `M₂.E` -/
lemma BinaryMatroid.DeltaSum.CircuitForm3.singleton_subset_M₂ {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    {p} ⊆ M₂.E :=
  (Set.union_subset_iff.→ hC.to_circuit_M₂.subset_ground).right

/-- Singleton element in definition of circuit form 3 lies in `M₁.E ∩ M₂.E` -/
lemma BinaryMatroid.DeltaSum.CircuitForm3.singleton_subset_inter {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    {p} ⊆ M₁.E ∩ M₂.E :=
  Set.subset_inter hC.singleton_subset_M₁ hC.singleton_subset_M₂

/-- Circuit of form 3 lies in `M₁.E ∪ M₂.E` -/
lemma BinaryMatroid.DeltaSum.CircuitForm3.subset_union {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    C ⊆ M₁.E ∪ M₂.E :=
  sub_union_diff_sub_union hC.subset_ground

/-- Circuit of form 3 is disjoint with `M₁.E ∩ M₂.E` -/
lemma BinaryMatroid.DeltaSum.CircuitForm3.disjoint_inter {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    C ⫗ M₁.E ∩ M₂.E :=
  Set.disjoint_of_subset_left hC.subset_ground (BinaryMatroid.DeltaSum.E.disjoint_inter M₁ M₂)

/-- Circuit of form 3 intersected with `M₁.E` is disjoint with `M₁.E ∩ M₂.E` -/
lemma BinaryMatroid.DeltaSum.CircuitForm3.disjoint_inter_M₁_inter {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    C ∩ M₁.E ⫗ M₁.E ∩ M₂.E :=
  hC.disjoint_inter.inter_left M₁.E

/-- Circuit of form 3 intersected with `M₁.E` is disjoint with `M₂.E` -/
lemma BinaryMatroid.DeltaSum.CircuitForm3.disjoint_inter_M₁_M₂ {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    C ∩ M₁.E ⫗ M₂.E := by
  rw [Set.disjoint_iff_inter_eq_empty, Set.inter_assoc, ←Set.disjoint_iff_inter_eq_empty]
  exact hC.disjoint_inter

/-- Circuit of form 3 intersected with `M₁.E` is disjoint with its intersection with `M₂.E` -/
lemma BinaryMatroid.DeltaSum.CircuitForm3.disjoint_inter_M₁_inter_M₂ {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    C ∩ M₁.E ⫗ C ∩ M₂.E :=
  Set.disjoint_of_subset_right Set.inter_subset_right hC.disjoint_inter_M₁_M₂

/-- Circuit of form 3 intersected with `M₂.E` is disjoint with `M₁.E ∩ M₂.E` -/
lemma BinaryMatroid.DeltaSum.CircuitForm3.disjoint_inter_M₂_inter {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    C ∩ M₂.E ⫗ M₁.E ∩ M₂.E :=
  hC.disjoint_inter.inter_left M₂.E

/-- Circuit of form 3 intersected with `M₂.E` is disjoint with `M₁.E` -/
lemma BinaryMatroid.DeltaSum.CircuitForm3.disjoint_inter_M₂_M₁ {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    C ∩ M₂.E ⫗ M₁.E := by
  rw [Set.disjoint_iff_inter_eq_empty, Set.inter_assoc, ←Set.disjoint_iff_inter_eq_empty, Set.inter_comm]
  exact hC.disjoint_inter

/-- Circuit of form 3 intersected with `M₂.E` is disjoint with its intersection with `M₁.E` -/
lemma BinaryMatroid.DeltaSum.CircuitForm3.disjoint_inter_M₂_inter_M₁ {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    C ∩ M₂.E ⫗ C ∩ M₁.E :=
  hC.disjoint_inter_M₁_inter_M₂.symm

/-- Circuit of form 3 has nonempty intersection with `M₁.E` provided {p} is not a circuit in `M₁` -/
lemma BinaryMatroid.DeltaSum.CircuitForm3.inter_M₁_nonempty {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) (hp : ¬(M₁.toMatroid.Circuit {p})) :
    (C ∩ M₁.E).Nonempty := by
  by_contra! C_inter_E₁_empty
  have hCM₁ := hC.to_circuit_M₁
  rw [C_inter_E₁_empty, Set.empty_union] at hCM₁
  exact hp hCM₁

/-- Circuit of form 3 has nonempty intersection with `M₂.E` provided {p} is not a circuit in `M₂` -/
lemma BinaryMatroid.DeltaSum.CircuitForm3.inter_M₂_nonempty {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) (hp : ¬(M₂.toMatroid.Circuit {p})) :
    (C ∩ M₂.E).Nonempty := by
  by_contra! C_inter_E₂_empty
  have hCM₂ := hC.to_circuit_M₂
  rw [C_inter_E₂_empty, Set.empty_union] at hCM₂
  exact hp hCM₂

/-- Circuit of form 3 intersected with `M₁.E` is disjoint with `{p}` -/
lemma BinaryMatroid.DeltaSum.CircuitForm3.disjoint_inter_M₁_p {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    C ∩ M₁.E ⫗ {p} :=
  Set.disjoint_of_subset_right hC.singleton_subset_inter hC.disjoint_inter_M₁_inter

/-- Circuit of form 3 intersected with `M₂.E` is disjoint with `{p}` -/
lemma BinaryMatroid.DeltaSum.CircuitForm3.disjoint_inter_M₂_p {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    C ∩ M₂.E ⫗ {p} :=
  Set.disjoint_of_subset_right hC.singleton_subset_inter hC.disjoint_inter_M₂_inter

/-- Circuit of form 3 is equal to symmetric difference of circuits in its definition -/
lemma BinaryMatroid.DeltaSum.CircuitForm3.eq_symmDiff {M₁ M₂ : BinaryMatroid α}
    (hC : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    C = symmDiff ((C ∩ M₁.E) ∪ {p}) ((C ∩ M₂.E) ∪ {p}) := by
  rw [
    symmDiff_def,
    Set.union_diff_distrib, ←Set.diff_diff,
    hC.disjoint_inter_M₁_inter_M₂.sdiff_eq_left, hC.disjoint_inter_M₁_p.sdiff_eq_left,
    Set.diff_eq_empty.← Set.subset_union_right, Set.union_empty,
    Set.union_diff_distrib, ←Set.diff_diff,
    hC.disjoint_inter_M₂_inter_M₁.sdiff_eq_left, hC.disjoint_inter_M₂_p.sdiff_eq_left,
    Set.diff_eq_empty.← Set.subset_union_right, Set.union_empty]
  exact hC.subset_union.parts_eq.symm

/-- Circuit of form 3 satisfies circuit form of `M₁ Δ M₂` provided it is nonempty -/
lemma BinaryMatroid.DeltaSum.CircuitForm3.circuit_form {M₁ M₂ : BinaryMatroid α}
    (hC : C.Nonempty) (hCp : BinaryMatroid.DeltaSum.CircuitForm3 M₁ M₂ C p) :
    BinaryMatroid.DeltaSum.CircuitForm M₁ M₂ C :=
  ⟨hC, hCp.subset_ground, C ∩ M₁.E ∪ {p}, C ∩ M₂.E ∪ {p},
    symmDiff_eq_alt _ _ ▸ hCp.eq_symmDiff,
    hCp.to_circuit_M₁.isUnionDisjointCircuits,
    hCp.to_circuit_M₂.isUnionDisjointCircuits⟩

end CircuitForm3

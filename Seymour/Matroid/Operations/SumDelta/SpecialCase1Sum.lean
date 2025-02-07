import Seymour.Matroid.Operations.Sum1.Basic
import Seymour.Matroid.Operations.SumDelta.CircuitForms


variable {α : Type} [DecidableEq α] {M₁ M₂ : BinaryMatroid α}


section CircuitFormsProperties

/-- Circuit of form 1 satisfies circuit predicate of `M₁ Δ M₂` if `M₁.E` and `M₂.E` are disjoint -/
lemma DeltaSumCircuitForm1.disjoint_circuit_pred {C : Set α}
    (hC : DeltaSumCircuitForm1 M₁ M₂ C) (hMM : M₁.E ⫗ M₂.E) :
    DeltaSumCircuitPred M₁ M₂ C := by
  constructor
  · exact hC.circuit_form
  · intro C' hC' hCC'
    obtain ⟨hC, hCE⟩ := hC
    obtain ⟨C'_nonempty, _, X₁, X₂, hXX, hX₁, hX₂⟩ := hC'
    rw [(Set.disjoint_of_subset hX₁.subset_ground hX₂.subset_ground hMM).inter_eq, Set.diff_empty] at hXX
    have X₂_empty : X₂ = ∅ := Set.subset_eq_empty
      (Set.disjoint_of_subset_left (hCC'.trans hC.subset_ground) hMM (Set.subset_union_right.trans hXX.symm.subset)
        hX₂.subset_ground) rfl
    rw [X₂_empty, Set.union_empty] at hXX
    rw [hXX] at hCC' C'_nonempty ⊢
    exact hC.right (hX₁.nonempty_dep C'_nonempty) hCC'

/-- Circuit of form 2 satisfies circuit predicate of `M₁ Δ M₂` if `M₁.E` and `M₂.E` are disjoint -/
lemma DeltaSumCircuitForm2.disjoint_circuit_pred {C : Set α}
    (hC : DeltaSumCircuitForm2 M₁ M₂ C) (hMM : M₁.E ⫗ M₂.E) :
    DeltaSumCircuitPred M₁ M₂ C := by
  constructor
  · exact hC.circuit_form
  · intro C' hC' hCC'
    obtain ⟨hC, hCE⟩ := hC
    unfold DeltaSumCircuitForm at hC'
    obtain ⟨C'_nonempty, _, X₁, X₂, hXX, hX₁, hX₂⟩ := hC'
    rw [(Set.disjoint_of_subset hX₁.subset_ground hX₂.subset_ground hMM).inter_eq, Set.diff_empty] at hXX
    have X₁_empty : X₁ = ∅ := Set.subset_eq_empty
      ((Set.disjoint_of_subset_right (hCC'.trans hC.subset_ground) hMM).symm (Set.subset_union_left.trans hXX.symm.subset)
        hX₁.subset_ground) rfl
    rw [X₁_empty, Set.empty_union] at hXX
    rw [hXX] at hCC' C'_nonempty ⊢
    exact hC.right (hX₂.nonempty_dep C'_nonempty) hCC'

end CircuitFormsProperties


section SpecialCase1sum

/-- If `M₁.E ∩ M₂.E = ∅`, then `M₁ Δ M₂ = M₁ ⊕ M₂` -/
lemma Disjoint.build1sum_eq_deltaSumMatroid (hE : M₁.toMatroid.E ⫗ M₂.toMatroid.E) :
    hE.build1sum = deltaSumMatroid M₁ M₂ := by
  apply Matroid.ext_circuit
  · erw [Matroid.disjointSum_ground_eq, VectorMatroid.toMatroid_E, VectorMatroid.toMatroid_E,
      deltaSumMatroid_E, hE.inter_eq, Set.diff_empty]
    rfl
  · intro C hCE
    rw [Matroid.disjointSum_ground_eq, VectorMatroid.toMatroid_E, VectorMatroid.toMatroid_E] at hCE
    rw [Matroid.build1sum_circuit_iff, deltaSumCircuitMatroid_circuit_iff]
    constructor
    · intro hC
      cases hC with
      | inl hCM₁ =>
        have hC₁ : DeltaSumCircuitForm1 M₁ M₂ C := ⟨hCM₁, disjoint_inter_disjoint C hE⟩
        exact hC₁.disjoint_circuit_pred hE
      | inr hCM₂ =>
        have hC₂ : DeltaSumCircuitForm2 M₁ M₂ C := ⟨hCM₂, disjoint_inter_disjoint C hE⟩
        exact hC₂.disjoint_circuit_pred hE
    · intro hC
      have hC' := hC
      have ⟨⟨_, hCE, X₁, X₂, hXX, hX₁, hX₂⟩, min_C⟩ := hC'
      if X₂_empty : X₂ = ∅ then
          left
          rw [X₂_empty, Set.union_empty, Set.inter_empty, Set.diff_empty] at hXX
          exact hC.udc_M₁ (hXX ▸ hX₁)
      else
        if X₁_empty : X₁ = ∅ then
          right
          rw [X₁_empty, Set.empty_union, Set.empty_inter, Set.diff_empty] at hXX
          exact hC.udc_M₂ (hXX ▸ hX₂)
        else
          apply Set.nonempty_iff_ne_empty.← at X₁_empty
          apply Set.nonempty_iff_ne_empty.← at X₂_empty
          have X₁_subset_E : X₁ ⊆ (M₁.E ∪ M₂.E) \ (M₁.E ∩ M₂.E)
          · erw [hE.inter_eq, Set.diff_empty]
            exact Set.subset_union_of_subset_left hX₁.subset_ground M₂.E
          have hXX' := Set.disjoint_of_subset hX₁.subset_ground hX₂.subset_ground hE
          rw [hXX'.inter_eq, Set.diff_empty] at hXX
          specialize min_C (deltaSumCircuitForm_left X₁_empty X₁_subset_E hX₁) (hXX.symm ▸ Set.subset_union_left)
          exact ((Set.ssubset_of_ssubset_of_subset (hXX ▸ ssubset_disjoint_union_nonempty hXX' X₂_empty) min_C).ne rfl).elim

end SpecialCase1sum

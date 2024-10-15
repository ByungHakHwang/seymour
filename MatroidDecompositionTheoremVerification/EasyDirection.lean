import Mathlib


/-- The finite field on two elements. -/
abbrev Z2 : Type := Fin 2

variable {X Y : Type} [DecidableEq X] [DecidableEq Y]

/-- Is given set of columns in the standard representation matrix independent? -/
def Matrix.IndepCols (A : Matrix X Y Z2) (S : Set (X ⊕ Y)) : Prop :=
  LinearIndependent Z2 ((Matrix.fromColumns 1 A).submatrix id ((↑) : S → X ⊕ Y)).transpose

/-- The empty set of columns in linearly independent. -/
theorem Matrix.IndepCols_empty (A : Matrix X Y Z2) : A.IndepCols ∅ := by
  sorry

/-- A subset of a linearly independent set of columns in linearly independent. -/
theorem Matrix.IndepCols_subset (A : Matrix X Y Z2) (I J : Set (X ⊕ Y)) (hAJ : A.IndepCols J) (hIJ : I ⊆ J) :
    A.IndepCols I := by
  sorry

/-- A nonmaximal linearly independent set of columns can be augmented with another linearly independent column. -/
theorem Matrix.IndepCols_aug (A : Matrix X Y Z2) (I B : Set (X ⊕ Y))
    (hAI : A.IndepCols I) (nonmax : ¬Maximal A.IndepCols I) (hAB : Maximal A.IndepCols B) :
    ∃ x ∈ B \ I, A.IndepCols (insert x I) := by
  sorry

/-- Any set of columns has the maximal subset property. -/
theorem Matrix.IndepCols_maximal (A : Matrix X Y Z2) (S : Set (X ⊕ Y)) :
    Matroid.ExistsMaximalSubsetProperty A.IndepCols S := by
  sorry

/-- Binary matroid generated by its standard representation matrix. -/
def Matrix.toIndepMatroid (A : Matrix X Y Z2) : IndepMatroid (X ⊕ Y) where
  E := Set.univ
  Indep := A.IndepCols
  indep_empty := A.IndepCols_empty
  indep_subset := A.IndepCols_subset
  indep_aug := A.IndepCols_aug
  indep_maximal S _ := A.IndepCols_maximal S
  subset_ground := fun _ _ _ _ => trivial

/-- Binary matroid on the ground set `(X ⊕ Y)`. -/
structure BinaryMatroid (X Y : Type) [DecidableEq X] [DecidableEq Y]
  extends IndepMatroid (X ⊕ Y) where
    B : Matrix X Y Z2
    hB : B.toIndepMatroid = toIndepMatroid

def Matrix.TU (A : Matrix X Y ℚ) : Prop :=
  ∀ k : ℕ, ∀ f : Fin k → X, ∀ g : Fin k → Y,
    Function.Injective f → Function.Injective g →
      (A.submatrix f g).det = 0 ∨
      (A.submatrix f g).det = 1 ∨
      (A.submatrix f g).det = -1

/-- Regular matroid on the ground set `(X ⊕ Y)`. -/
structure RegularMatroid (X Y : Type) [DecidableEq X] [DecidableEq Y]
  extends BinaryMatroid X Y where
    A : Matrix X Y ℚ
    hA : (Matrix.fromColumns (1 : Matrix X X ℚ) A).TU
    hBA : ∀ i : X, ∀ j : Y, if B i j = 0 then A i j = 0 else A i j = 1 ∨ A i j = -1

/-- Matroid casting, i.e., renaming the type without changing the elements; implemented for independent sets. -/
def IndepMatroid.cast (M : IndepMatroid X) (hXY : X = Y) : IndepMatroid Y where
  E := hXY ▸ M.E
  Indep := hXY ▸ M.Indep
  indep_empty := by subst hXY; exact M.indep_empty
  indep_subset := by subst hXY; exact M.indep_subset
  indep_aug := by subst hXY; exact M.indep_aug
  indep_maximal := by subst hXY; exact M.indep_maximal
  subset_ground := by subst hXY; exact M.subset_ground

/-- Matroid isomorphism, i.e., renaming the elements; implemented for matroids defined by independent sets. -/
def IndepMatroid.mapEquiv (M : IndepMatroid X) (eXY : X ≃ Y) : IndepMatroid Y where
  E := eXY '' M.E
  Indep I := ∃ I₀, M.Indep I₀ ∧ I = eXY '' I₀
  indep_empty := ⟨∅, M.indep_empty, (Set.image_empty eXY).symm⟩
  indep_subset I J hI hJ := by
    refine ⟨eXY.symm '' I, ?_, by rw [Equiv.eq_image_iff_symm_image_eq eXY]⟩
    obtain ⟨I', hIJ⟩ := hI
    have := M.indep_subset (I := eXY.symm '' I) (J := eXY.symm '' J)
    simp_all
  indep_aug := by sorry
  indep_maximal I := by sorry
  subset_ground I hI := by have := M.subset_ground (eXY.symm '' I); aesop

variable {X₁ X₂ Y₁ Y₂ : Type} [DecidableEq X₁] [DecidableEq Y₁] [DecidableEq X₂] [DecidableEq Y₂]

/-- Matrix-level 1-sum for matroids defined by their standard representation matrices. -/
def Matrix.OneSumComposition (A₁ : Matrix X₁ Y₁ Z2) (A₂ : Matrix X₂ Y₂ Z2) :
    Matrix (X₁ ⊕ X₂) (Y₁ ⊕ Y₂) Z2 :=
  Matrix.fromBlocks A₁ 0 0 A₂

/-- Matrix-level 2-sum for matroids defined by their standard representation matrices; does not check legitimacy. -/
def Matrix.TwoSumComposition (A₁ : Matrix X₁ Y₁ Z2) (x : Y₁ → Z2) (A₂ : Matrix X₂ Y₂ Z2) (y : X₂ → Z2) :
    Matrix (X₁ ⊕ X₂) (Y₁ ⊕ Y₂) Z2 :=
  Matrix.fromBlocks A₁ 0 (fun i j => y i * x j) A₂

/-- Matrix-level 3-sum for matroids defined by their standard representation matrices; does not check legitimacy. -/
noncomputable def Matrix.ThreeSumComposition (A₁ : Matrix X₁ (Y₁ ⊕ Fin 2) Z2) (A₂ : Matrix (Fin 2 ⊕ X₂) Y₂ Z2)
    (z₁ : Y₁ → Z2) (z₂ : X₂ → Z2)
    (D : Matrix (Fin 2) (Fin 2) Z2) (D₁ : Matrix (Fin 2) Y₁ Z2) (D₂ : Matrix X₂ (Fin 2) Z2) :
    Matrix ((X₁ ⊕ Unit) ⊕ (Fin 2 ⊕ X₂)) ((Y₁ ⊕ Fin 2) ⊕ (Unit ⊕ Y₂)) Z2 :=
  let D₁₂ : Matrix X₂ Y₁ Z2 := D₂ * D⁻¹ * D₁
  Matrix.fromBlocks
    (Matrix.fromRows A₁ (Matrix.row Unit (Sum.elim z₁ ![1, 1]))) 0
    (Matrix.fromBlocks D₁ D D₁₂ D₂) (Matrix.fromColumns (Matrix.col Unit (Sum.elim ![1, 1] z₂)) A₂)

/-- Matroid-level (independent sets) 1-sum for matroids defined by their standard representation matrices. -/
def BinaryMatroid.OneSum (M₁ : BinaryMatroid X₁ Y₁) (M₂ : BinaryMatroid X₂ Y₂) :
    IndepMatroid ((X₁ ⊕ X₂) ⊕ (Y₁ ⊕ Y₂)) :=
  (Matrix.OneSumComposition M₁.B M₂.B).toIndepMatroid -- TODO refactor to return `BinaryMatroid`

/-- Matroid-level 2-sum for matroids defined by their standard representation matrices; does not check legitimacy. -/
def BinaryMatroid.TwoSum (M₁ : BinaryMatroid (X₁ ⊕ Unit) Y₁) (M₂ : BinaryMatroid X₂ (Unit ⊕ Y₂)) :
    IndepMatroid ((X₁ ⊕ X₂) ⊕ (Y₁ ⊕ Y₂)) :=
  let B₁ := M₁.B -- the standard representation matrix of `M₁`
  let B₂ := M₂.B -- the standard representation matrix of `M₂`
  let A₁ : Matrix X₁ Y₁ Z2 := B₁ ∘ .inl -- the top submatrix
  let A₂ : Matrix X₂ Y₂ Z2 := (B₂ · ∘ .inr) -- the right submatrix
  let x : Y₁ → Z2 := (B₁ ∘ .inr) ()       -- makes sense only if `x ≠ 0`
  let y : X₂ → Z2 := ((B₂ · ∘ .inl) · ()) -- makes sense only if `y ≠ 0`
  (Matrix.TwoSumComposition A₁ x A₂ y).toIndepMatroid -- TODO refactor to return `BinaryMatroid`

/-- Matroid-level 3-sum for matroids defined by their standard representation matrices; does not check legitimacy. -/
def BinaryMatroid.ThreeSum
    (M₁ : BinaryMatroid ((X₁ ⊕ Unit) ⊕ Fin 2) ((Y₁ ⊕ Fin 2) ⊕ Unit))
    (M₂ : BinaryMatroid (Unit ⊕ (Fin 2 ⊕ X₂)) (Fin 2 ⊕ (Unit ⊕ Y₂))) :
    IndepMatroid (((X₁ ⊕ Unit) ⊕ (Fin 2 ⊕ X₂)) ⊕ ((Y₁ ⊕ Fin 2) ⊕ (Unit ⊕ Y₂))) :=
  let B₁ := M₁.B -- the standard representation matrix of `M₁`
  let B₂ := M₂.B -- the standard representation matrix of `M₂`
  let A₁ : Matrix X₁ (Y₁ ⊕ Fin 2) Z2 := ((B₁ ∘ .inl ∘ .inl) · ∘ .inl) -- the top left submatrix
  let A₂ : Matrix (Fin 2 ⊕ X₂) Y₂ Z2 := ((B₂ ∘ .inr) · ∘ .inr ∘ .inr) -- the bottom right submatrix
  let z₁ : Y₁ → Z2 := fun j => B₁ (.inl (.inr ())) (.inl (.inl j)) -- the middle left "row vector"
  let z₂ : X₂ → Z2 := fun i => B₂ (.inr (.inr i)) (.inr (.inl ())) -- the bottom middle "column vector"
  let D : Matrix (Fin 2) (Fin 2) Z2 := fun i j => B₁ (.inr i) (.inl (.inr j)) -- the bottom middle 2x2 submatrix
  let D : Matrix (Fin 2) (Fin 2) Z2 := fun i j => B₂ (.inr (.inl i)) (.inl j) -- the middle left 2x2 submatrix
  -- TODO require both `D` are identical
  -- TODO require that `D` is regular
  let D₁ : Matrix (Fin 2) Y₁ Z2 := fun i j => B₁ (.inr i) (.inl (.inl j)) -- the bottom left submatrix
  let D₂ : Matrix X₂ (Fin 2) Z2 := fun i j => B₂ (.inr (.inr i)) (.inl j) -- the bottom left submatrix
  (Matrix.ThreeSumComposition A₁ A₂ z₁ z₂ D D₁ D₂).toIndepMatroid -- TODO refactor to return `BinaryMatroid`

/-- Matroid `M` is a result of 1-summing `M₁` and `M₂` (should be equivalent to direct sums). -/
def BinaryMatroid.IsOneSum (M : BinaryMatroid X Y) (M₁ : BinaryMatroid X₁ Y₁) (M₂ : BinaryMatroid X₂ Y₂) : Prop :=
  ∃ eX : X ≃ (X₁ ⊕ X₂), ∃ eY : Y ≃ (Y₁ ⊕ Y₂),
    M.toIndepMatroid = (BinaryMatroid.OneSum M₁ M₂).mapEquiv (Equiv.sumCongr eX eY).symm

/-- Matroid `M` is a result of 2-summing `M₁` and `M₂` in some way. -/
def BinaryMatroid.IsTwoSum (M : BinaryMatroid X Y) (M₁ : BinaryMatroid X₁ Y₁) (M₂ : BinaryMatroid X₂ Y₂) : Prop :=
  let B₁ := M₁.B -- the standard representation matrix of `M₁`
  let B₂ := M₂.B -- the standard representation matrix of `M₂`
  ∃ X' Y' : Type, ∃ _ : DecidableEq X', ∃ _ : DecidableEq Y', -- indexing types for the shared parts
    ∃ hX : X₁ = (X' ⊕ Unit), ∃ hY : Y₂ = (Unit ⊕ Y'), ∃ eX : X ≃ (X' ⊕ X₂), ∃ eY : Y ≃ (Y₁ ⊕ Y'),
      M.toIndepMatroid = IndepMatroid.mapEquiv (
        BinaryMatroid.TwoSum
          ⟨M₁.cast (congr_arg (· ⊕ Y₁) hX), hX ▸ B₁, by subst hX; convert M₁.hB⟩
          ⟨M₂.cast (congr_arg (X₂ ⊕ ·) hY), hY ▸ B₂, by subst hY; convert M₂.hB⟩
      ) (Equiv.sumCongr eX eY).symm ∧
      (hX ▸ B₁) (Sum.inr ()) ≠ (0 : Y₁ → Z2) ∧ -- the requirement `x ≠ 0`
      (fun i : X₂ => (hY ▸ B₂ i) (Sum.inl ())) ≠ (0 : X₂ → Z2) -- the requirement `y ≠ 0`

/-- Matroid `M` is a result of 3-summing `M₁` and `M₂` in some way. -/
def BinaryMatroid.IsThreeSum (M : BinaryMatroid X Y) (M₁ : BinaryMatroid X₁ Y₁) (M₂ : BinaryMatroid X₂ Y₂) : Prop :=
  let B₁ := M₁.B -- the standard representation matrix of `M₁`
  let B₂ := M₂.B -- the standard representation matrix of `M₂`
  ∃ X₁' Y₁' : Type, ∃ _ : DecidableEq X₁', ∃ _ : DecidableEq Y₁', -- indexing types for the shared parts
  ∃ X₂' Y₂' : Type, ∃ _ : DecidableEq X₂', ∃ _ : DecidableEq Y₂', -- indexing types for the shared parts
    ∃ hX₁ : X₁ = ((X₁' ⊕ Unit) ⊕ Fin 2), ∃ hY₁ : Y₁ = ((Y₁' ⊕ Fin 2) ⊕ Unit),
    ∃ hX₂ : X₂ = (Unit ⊕ (Fin 2 ⊕ X₂')), ∃ hY₂ : Y₂ = (Fin 2 ⊕ (Unit ⊕ Y₂')),
      ∃ eX : X ≃ ((X₁' ⊕ Unit) ⊕ (Fin 2 ⊕ X₂')), ∃ eY : Y ≃ ((Y₁' ⊕ Fin 2) ⊕ (Unit ⊕ Y₂')),
        M.toIndepMatroid = IndepMatroid.mapEquiv (
          BinaryMatroid.ThreeSum
            ⟨M₁.cast (by subst hX₁ hY₁; rfl), hX₁ ▸ hY₁ ▸ B₁, (by subst hX₁ hY₁; convert M₁.hB)⟩
            ⟨M₂.cast (by subst hX₂ hY₂; rfl), hX₂ ▸ hY₂ ▸ B₂, (by subst hX₂ hY₂; convert M₂.hB)⟩
        ) (Equiv.sumCongr eX eY).symm ∧
        True ∧ -- TODO require `Invertible D`
        True -- TODO require consistency between
             -- the bottom middle 2x2 submatrix of `B₁` and the middle left 2x2 submatrix of `B₂`

/-- Any 1-sum of regular matroids is a regular matroid. -/
noncomputable
def BinaryMatroid.IsOneSum.toRegular {M : BinaryMatroid X Y} {M₁ : RegularMatroid X₁ Y₁} {M₂ : RegularMatroid X₂ Y₂}
    (hM : M.IsOneSum M₁.toBinaryMatroid M₂.toBinaryMatroid) :
    RegularMatroid X Y where
  toBinaryMatroid := M
  A := sorry
  hA := sorry
  hBA := sorry

/-- Any 2-sum of regular matroids is a regular matroid. -/
noncomputable
def BinaryMatroid.IsTwoSum.toRegular {M : BinaryMatroid X Y} {M₁ : RegularMatroid X₁ Y₁} {M₂ : RegularMatroid X₂ Y₂}
    (hM : M.IsTwoSum M₁.toBinaryMatroid M₂.toBinaryMatroid) :
    RegularMatroid X Y where
  toBinaryMatroid := M
  A := sorry
  hA := sorry
  hBA := sorry

/-- Any 3-sum of regular matroids is a regular matroid. -/
noncomputable
def BinaryMatroid.IsThreeSum.toRegular {M : BinaryMatroid X Y} {M₁ : RegularMatroid X₁ Y₁} {M₂ : RegularMatroid X₂ Y₂}
    (hM : M.IsThreeSum M₁.toBinaryMatroid M₂.toBinaryMatroid) :
    RegularMatroid X Y where
  toBinaryMatroid := M
  A := sorry
  hA := sorry
  hBA := sorry
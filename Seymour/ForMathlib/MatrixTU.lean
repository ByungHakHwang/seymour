import Mathlib.Data.Matrix.ColumnRowPartitioned
import Mathlib.Data.Matrix.Rank
import Seymour.ForMathlib.Basic

/-!
This file defines totally unimodular matrices and provides lemmas about them.
It will be soon replaced by the implementation that got into Mathlib (slighlty different but mathematically equivalent).
-/

attribute [-simp] Fintype.card_ofIsEmpty Fintype.card_ofSubsingleton -- major performance issue

open scoped Matrix

variable {X Y R : Type*} [CommRing R]

/-- Is the matrix `A` totally unimodular? -/
def Matrix.TU (A : Matrix X Y R) : Prop :=
  ∀ k : ℕ, ∀ f : Fin k → X, ∀ g : Fin k → Y, f.Injective → g.Injective →
    (A.submatrix f g).det = 0 ∨
    (A.submatrix f g).det = 1 ∨
    (A.submatrix f g).det = -1

lemma Matrix.TU_iff (A : Matrix X Y R) : A.TU ↔
    ∀ k : ℕ, ∀ f : Fin k → X, ∀ g : Fin k → Y,
      (A.submatrix f g).det = 0 ∨
      (A.submatrix f g).det = 1 ∨
      (A.submatrix f g).det = -1
    := by
  constructor <;> intro hA
  · intro k f g
    if hf : f.Injective then
      if hg : g.Injective then
        exact hA k f g hf hg
      else
        left
        rw [g.not_injective_iff] at hg
        obtain ⟨i, j, hqij, hij⟩ := hg
        apply Matrix.det_zero_of_column_eq hij
        intro
        simp [hqij]
    else
      left
      rw [f.not_injective_iff] at hf
      obtain ⟨i, j, hpij, hij⟩ := hf
      apply Matrix.det_zero_of_row_eq
      · exact hij
      show (A (f i)) ∘ (g ·) = (A (f j)) ∘ (g ·)
      rw [hpij]
  · intro _ _ _ _ _
    apply hA

lemma Matrix.TU_iff_fntp.{u} (A : Matrix X Y R) : A.TU ↔
    ∀ (ι : Type u) [Fintype ι] [DecidableEq ι], ∀ f : ι → X, ∀ g : ι → Y,
      (A.submatrix f g).det = 0 ∨
      (A.submatrix f g).det = 1 ∨
      (A.submatrix f g).det = -1
    := by
  rw [Matrix.TU_iff]
  constructor
  · intro hA ι _ _ f g
    specialize hA (Fintype.card ι) (f ∘ (Fintype.equivFin ι).symm) (g ∘ (Fintype.equivFin ι).symm)
    rwa [←Matrix.submatrix_submatrix, Matrix.det_submatrix_equiv_self] at hA
  · intro hA k f g
    specialize hA (ULift (Fin k)) (f ∘ Equiv.ulift) (g ∘ Equiv.ulift)
    rw [←Matrix.submatrix_submatrix] at hA
    convert hA <;> rw [Matrix.det_submatrix_equiv_self]

lemma Matrix.TU.apply {A : Matrix X Y R} (hA : A.TU) (i : X) (j : Y) :
    A i j = 0 ∨ A i j = 1 ∨ A i j = -1 := by
  rw [Matrix.TU_iff] at hA
  convert hA 1 (fun _ => i) (fun _ => j) <;> simp

lemma Matrix.TU.submatrix {A : Matrix X Y R} (hA : A.TU) {X' Y' : Type*} (f : X' → X) (g : Y' → Y) :
    (A.submatrix f g).TU := by
  intro _ _ _ _ _
  rw [Matrix.submatrix_submatrix]
  rw [Matrix.TU_iff] at hA
  apply hA

lemma Matrix.TU.transpose {A : Matrix X Y R} (hA : A.TU) : Aᵀ.TU := by
  intro _ _ _ _ _
  simp only [←Matrix.transpose_submatrix, Matrix.det_transpose]
  apply hA <;> assumption

lemma Matrix.TU_iff_transpose (A : Matrix X Y R) : A.TU ↔ Aᵀ.TU := by
  constructor <;> apply Matrix.TU.transpose

lemma Matrix.mapEquiv_rows_TU {X' : Type*} [DecidableEq X']
    (A : Matrix X Y R) (eX : X' ≃ X) :
    Matrix.TU (A ∘ eX) ↔ A.TU := by
  rw [Matrix.TU_iff, Matrix.TU_iff]
  constructor <;> intro hA k f g
  · simpa [Matrix.submatrix] using hA k (eX.symm ∘ f) g
  · simpa [Matrix.submatrix] using hA k (eX ∘ f) g

lemma Matrix.TU.comp_rows {X' : Type*} {A : Matrix X Y R}
    (hA : A.TU) (e : X' → X) :
    Matrix.TU (A ∘ e) := by
  rw [Matrix.TU_iff] at hA ⊢
  intro k f g
  exact hA k (e ∘ f) g

lemma Matrix.mapEquiv_cols_TU {Y' : Type*} [DecidableEq Y']
    (A : Matrix X Y R) (eY : Y' ≃ Y) :
    Matrix.TU (A · ∘ eY) ↔ A.TU := by
  rw [Matrix.TU_iff, Matrix.TU_iff]
  constructor <;> intro hA k f g
  · simpa [Matrix.submatrix] using hA k f (eY.symm ∘ g)
  · simpa [Matrix.submatrix] using hA k f (eY ∘ g)

lemma Matrix.TU.comp_cols {Y' : Type*} {A : Matrix X Y R}
    (hA : A.TU) (e : Y' → Y) :
    Matrix.TU (A · ∘ e) := by
  rw [Matrix.TU_iff] at hA ⊢
  intro k f g
  exact hA k f (e ∘ g)

lemma Matrix.mapEquiv_both_TU {X' Y' : Type*} [DecidableEq X'] [DecidableEq Y']
    (A : Matrix X Y R) (eX : X' ≃ X) (eY : Y' ≃ Y) :
    Matrix.TU ((A · ∘ eY) ∘ eX) ↔ A.TU := by
  rw [Matrix.mapEquiv_rows_TU, Matrix.mapEquiv_cols_TU]

lemma Matrix.TU_adjoin_row0s_iff (A : Matrix X Y R) {X' : Type*} :
    (Matrix.fromRows A (Matrix.row X' 0)).TU ↔ A.TU := by
  rw [Matrix.TU_iff, Matrix.TU_iff]
  constructor <;> intro hA k f g
  · exact hA k (Sum.inl ∘ f) g
  · if zerow : ∃ i, ∃ x', f i = Sum.inr x' then
      obtain ⟨i, _, _⟩ := zerow
      left
      apply Matrix.det_eq_zero_of_row_eq_zero i
      intro
      simp_all
    else
      obtain ⟨_, rfl⟩ : ∃ f₀ : Fin k → X, f = Sum.inl ∘ f₀
      · have hi (i : Fin k) : ∃ x, f i = Sum.inl x :=
          match hfi : f i with
          | .inl x => ⟨x, rfl⟩
          | .inr x => (zerow ⟨i, x, hfi⟩).elim
        choose f₀ hf₀ using hi
        use f₀
        ext
        apply hf₀
      apply hA

-- Bhavik Mehta proved: https://github.com/leanprover-community/mathlib4/pull/19076
lemma Matrix.TU_adjoin_id_below_iff [DecidableEq X] [DecidableEq Y] (A : Matrix X Y R) :
    (Matrix.fromRows A (1 : Matrix Y Y R)).TU ↔ A.TU := by
  sorry

lemma Matrix.TU_adjoin_id_above_iff [DecidableEq X] [DecidableEq Y] (A : Matrix X Y R) :
    (Matrix.fromRows (1 : Matrix Y Y R) A).TU ↔ A.TU := by
  rw [←Matrix.mapEquiv_rows_TU (Matrix.fromRows (1 : Matrix Y Y R) A) (Equiv.sumComm X Y)]
  convert Matrix.TU_adjoin_id_below_iff A
  aesop

lemma Matrix.TU_adjoin_id_left_iff [DecidableEq X] [DecidableEq Y] (A : Matrix X Y R) :
    (Matrix.fromColumns (1 : Matrix X X R) A).TU ↔ A.TU := by
  rw [Matrix.TU_iff_transpose, Matrix.transpose_fromColumns, Matrix.transpose_one, Matrix.TU_iff_transpose A]
  exact Matrix.TU_adjoin_id_above_iff Aᵀ

lemma Matrix.TU_adjoin_id_right_iff [DecidableEq X] [DecidableEq Y] (A : Matrix X Y R) :
    (Matrix.fromColumns A (1 : Matrix X X R)).TU ↔ A.TU := by
  rw [←Matrix.mapEquiv_cols_TU (Matrix.fromColumns A (1 : Matrix X X R)) (Equiv.sumComm X Y)]
  convert Matrix.TU_adjoin_id_left_iff A
  aesop

variable {X₁ X₂ Y₁ Y₂ : Type*}

lemma Matrix.fromColumns_zero_rank [Fintype Y₁] [Fintype Y₂] (A : Matrix X Y₂ R) :
    (Matrix.fromColumns (0 : Matrix X Y₁ R) A).rank = A.rank := by
  sorry

lemma Matrix.fromRows_rank_subadditive [Fintype Y] (A₁ : Matrix X₁ Y R) (A₂ : Matrix X₂ Y R) :
    (Matrix.fromRows A₁ A₂).rank ≤ A₁.rank + A₂.rank := by
  sorry

-- Jireh Loreaux proved (but a more general version might land into Mathlib soonish):
lemma Matrix.det_zero_of_rank_lt {R : Type*} [LinearOrderedField R] [Fintype X] [DecidableEq X] {A : Matrix X X R}
    (hA: A.rank < Fintype.card X) :
    A.det = 0 := by
  contrapose! hA
  rw [←isUnit_iff_ne_zero, ←Matrix.isUnit_iff_isUnit_det] at hA
  exact (A.rank_of_isUnit hA).symm.le

lemma Matrix.fromBlocks_submatrix_apply {β ι γ : Type*} (f : ι → X₁ ⊕ X₂) (g : γ → Y₁ ⊕ Y₂)
    (A₁₁ : Matrix X₁ Y₁ β) (A₁₂ : Matrix X₁ Y₂ β) (A₂₁ : Matrix X₂ Y₁ β) (A₂₂ : Matrix X₂ Y₂ β) (i : ι) (j : γ) :
    (Matrix.fromBlocks A₁₁ A₁₂ A₂₁ A₂₂).submatrix f g i j =
    match f i with
    | .inl i₁ =>
      match g j with
      | .inl j₁ => A₁₁ i₁ j₁
      | .inr j₂ => A₁₂ i₁ j₂
    | .inr i₂ =>
      match g j with
      | .inl j₁ => A₂₁ i₂ j₁
      | .inr j₂ => A₂₂ i₂ j₂
    := by
  aesop

omit R

lemma Matrix.submatrix_det_abs {R : Type*} [LinearOrderedCommRing R]
    [Fintype X] [DecidableEq X] [Fintype Y] [DecidableEq Y]
    (A : Matrix X X R) (e₁ e₂ : Y ≃ X) :
    |(A.submatrix e₁ e₂).det| = |A.det| := by
  have hee : e₂ = e₁.trans (e₁.symm.trans e₂)
  · ext
    simp
  have hAee : A.submatrix e₁ (e₁.trans (e₁.symm.trans e₂)) = (A.submatrix id (e₁.symm.trans e₂)).submatrix e₁ e₁
  · rfl
  rw [hee, hAee, Matrix.det_submatrix_equiv_self, Matrix.det_permute']
  cases' Int.units_eq_one_or (Equiv.Perm.sign (e₁.symm.trans e₂)) with he he <;> rw [he] <;> simp

lemma Matrix.submatrix_det_abs' {R : Type*} [LinearOrderedCommRing R]
    [Fintype X₁] [DecidableEq X₁] [Fintype X₂] [DecidableEq X₂] [Fintype Y] [DecidableEq Y]
    (A : Matrix X₁ X₂ R) (e₁ : Y ≃ X₁) (e₂ : Y ≃ X₂) :
    |(A.submatrix e₁ e₂).det| = |(A.submatrix (e₂.symm.trans e₁) id).det| := by
  sorry -- might be useless in the end

/-- A matrix composed of TU blocks on the diagonal is TU. -/
lemma Matrix.fromBlocks_TU {R : Type*} [LinearOrderedField R]
    [Fintype X₁] [DecidableEq X₁] [Fintype Y₁] [DecidableEq Y₁] [Fintype X₂] [DecidableEq X₂] [Fintype Y₂] [DecidableEq Y₂]
    {A₁ : Matrix X₁ Y₁ R} {A₂ : Matrix X₂ Y₂ R}
    (hA₁ : A₁.TU) (hA₂ : A₂.TU) :
    (Matrix.fromBlocks A₁ 0 0 A₂).TU := by
  intro k f g hf hg
  rw [Matrix.TU_iff] at hA₁ hA₂
  rw [f.eq_comp_myEquiv, g.eq_comp_myEquiv, ←Matrix.submatrix_submatrix]
  -- submatrix of a block matrix is a block matrix of submatrices
  have hAfg :
    (Matrix.fromBlocks A₁ 0 0 A₂).submatrix
      (Sum.elim (Sum.inl ∘ (·.val.snd)) (Sum.inr ∘ (·.val.snd)))
      (Sum.elim (Sum.inl ∘ (·.val.snd)) (Sum.inr ∘ (·.val.snd)))
    =
    Matrix.fromBlocks
      (A₁.submatrix
        ((·.val.snd) : { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd } → X₁)
        ((·.val.snd) : { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } → Y₁)
      ) 0 0
      (A₂.submatrix
        ((·.val.snd) : { x₂ : Fin k × X₂ // f x₂.fst = Sum.inr x₂.snd } → X₂)
        ((·.val.snd) : { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } → Y₂)
      )
  · ext i j
    cases i <;> cases j <;> simp
  rw [hAfg]
  clear hAfg
  -- look at sizes of submatrices in blocks
  if hxy : Fintype.card { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd } = Fintype.card { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd }
         ∧ Fintype.card { x₂ : Fin k × X₂ // f x₂.fst = Sum.inr x₂.snd } = Fintype.card { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd }
  then -- square case
    obtain ⟨cardi₁, cardi₂⟩ := hxy
    -- equivalences between canonical indexing types of given cardinality and current indexing types (domains of parts of indexing functions)
    let eX₁ : Fin (Fintype.card { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd }) ≃ { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd } :=
      (Fintype.equivFin { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd }).symm
    let eX₂ : Fin (Fintype.card { x₂ : Fin k × X₂ // f x₂.fst = Sum.inr x₂.snd }) ≃ { x₂ : Fin k × X₂ // f x₂.fst = Sum.inr x₂.snd } :=
      (Fintype.equivFin { x₂ : Fin k × X₂ // f x₂.fst = Sum.inr x₂.snd }).symm
    let eY₁ : Fin (Fintype.card { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd }) ≃ { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } :=
      (cardi₁ ▸ Fintype.equivFin { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd }).symm
    let eY₂ : Fin (Fintype.card { x₂ : Fin k × X₂ // f x₂.fst = Sum.inr x₂.snd }) ≃ { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } :=
      (cardi₂ ▸ Fintype.equivFin { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd }).symm
    -- relating submatrices in blocks to submatrices of `A₁` and `A₂`
    -- metaphor: function `h` in `f ∘ h` is not bijective, but `f ∘ h` is `(f ∘ g) ∘ (g⁻¹ ∘ h)` where `g⁻¹ ∘ h` is bijective
    have hAfg' :
      (Matrix.fromBlocks
        (A₁.submatrix
          ((·.val.snd) : { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd } → X₁)
          ((·.val.snd) : { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } → Y₁)
        ) 0 0
        (A₂.submatrix
          ((·.val.snd) : { x₂ : Fin k × X₂ // f x₂.fst = Sum.inr x₂.snd } → X₂)
          ((·.val.snd) : { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } → Y₂)
        )).submatrix
          f.myEquiv
          g.myEquiv
      =
      (Matrix.fromBlocks
        (A₁.submatrix
          (((·.val.snd) : { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd } → X₁) ∘ eX₁)
          (((·.val.snd) : { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } → Y₁) ∘ eY₁)
        ) 0 0
        (A₂.submatrix
          (((·.val.snd) : { x₂ : Fin k × X₂ // f x₂.fst = Sum.inr x₂.snd } → X₂) ∘ eX₂)
          (((·.val.snd) : { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } → Y₂) ∘ eY₂)
        )).submatrix
          (f.myEquiv.trans (Equiv.sumCongr eX₁.symm eX₂.symm))
          (g.myEquiv.trans (Equiv.sumCongr eY₁.symm eY₂.symm))
    · ext
      simp only [Function.myEquiv, Equiv.coe_fn_mk, Equiv.coe_trans, Equiv.sumCongr_apply, Function.comp_apply,
        Matrix.submatrix, Matrix.fromBlocks, Matrix.of_apply]
      split
      · split
        · simp
        · rfl
      · split
        · rfl
        · simp
    -- absolute value of determinant was preserved by previous mappings
    -- we now express it as a product of determinants of submatrices in blocks
    rw [hAfg', ←abs_eq_zero, ←abs_eq_one, Matrix.submatrix_det_abs, Matrix.det_fromBlocks_zero₁₂, abs_eq_zero, abs_eq_one]
    -- determinants of submatrices in blocks are `0` or `±1` by TUness of `A₁` and `A₂`
    apply zom_mul_zom
    · apply hA₁
    · apply hA₂
  else -- non-square case
    -- both submatrices in blocks are non-square
    obtain ⟨cardine₁, cardine₂⟩ :
        Fintype.card { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd } ≠
        Fintype.card { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } ∧
        Fintype.card { x₂ : Fin k × X₂ // f x₂.fst = Sum.inr x₂.snd } ≠
        Fintype.card { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd }
    · rw [not_and_or] at hxy
      have hk₁ := Fintype.card_fin k ▸ Fintype.card_congr f.myEquiv
      have hk₂ := Fintype.card_fin k ▸ Fintype.card_congr g.myEquiv
      rw [Fintype.card_sum] at hk₁ hk₂
      cases hxy <;> omega
    clear hxy
    -- goal: prove that `det` is `0`
    left
    if hxy₁ : Fintype.card { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd }
            < Fintype.card { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd }
    then
      -- we need to prove that the bottom half of our submatrix does not have maximal rank
      rw [←abs_eq_zero, Matrix.submatrix_det_abs']
      have hAfg'' :
        (Matrix.fromBlocks
          (A₁.submatrix
            ((·.val.snd) : { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd } → X₁)
            ((·.val.snd) : { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } → Y₁)
          ) 0 0
          (A₂.submatrix
            ((·.val.snd) : { x₂ : Fin k × X₂ // f x₂.fst = Sum.inr x₂.snd } → X₂)
            ((·.val.snd) : { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } → Y₂)
          )).submatrix
            (g.myEquiv.symm.trans f.myEquiv)
            id
        =
        (Matrix.fromBlocks
          (A₁.submatrix
            ((·.val.snd) : { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd } → X₁)
            ((·.val.snd) : { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } → Y₁)
          ) 0 0
          (A₂.submatrix
            ((·.val.snd) : { x₂ : Fin k × X₂ // f x₂.fst = Sum.inr x₂.snd } → X₂)
            ((·.val.snd) : { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } → Y₂)
          )).submatrix
            (fun z =>
              match hfg : f (g.myEquiv.symm z) with
              | Sum.inl b₁ => Sum.inl ⟨⟨g.myEquiv.symm z, b₁⟩, hfg⟩
              | Sum.inr b₂ => Sum.inr ⟨⟨g.myEquiv.symm z, b₂⟩, hfg⟩
            ) /-
              intro x
              by cases x with
              | inl x₁ =>
                exact
                  match hfg : f (g.myEquiv.symm (Sum.inl x₁)) with
                  | Sum.inl b₁ => Sum.inl ⟨⟨x₁.val.fst, b₁⟩, hfg⟩
                  | Sum.inr b₂ => Sum.inr ⟨⟨x₁.val.fst, b₂⟩, hfg⟩
              | inr x₂ =>
                exact
                  match hfg : f (g.myEquiv.symm (Sum.inr x₂)) with
                  | Sum.inl b₁ => Sum.inl ⟨⟨x₂.val.fst, b₁⟩, hfg⟩
                  | Sum.inr b₂ => Sum.inr ⟨⟨x₂.val.fst, b₂⟩, hfg⟩
              -/
            (Equiv.refl _)
      · rfl
      have hAfg''' :
        (Matrix.fromBlocks
          (A₁.submatrix
            ((·.val.snd) : { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd } → X₁)
            ((·.val.snd) : { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } → Y₁)
          ) 0 0
          (A₂.submatrix
            ((·.val.snd) : { x₂ : Fin k × X₂ // f x₂.fst = Sum.inr x₂.snd } → X₂)
            ((·.val.snd) : { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } → Y₂)
          )).submatrix
            (fun z =>
              match hfg : f (g.myEquiv.symm z) with
              | Sum.inl b₁ => Sum.inl ⟨⟨g.myEquiv.symm z, b₁⟩, hfg⟩
              | Sum.inr b₂ => Sum.inr ⟨⟨g.myEquiv.symm z, b₂⟩, hfg⟩
            )
            (Equiv.refl _)
        =
        (Matrix.fromBlocks
          (A₁.submatrix
            (((·.val.snd) : { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd } → X₁) ∘ (
              fun z =>
                match hfg : f z.val.fst with
                | Sum.inl b₁ => ⟨⟨z.val.fst, b₁⟩, hfg⟩
                | Sum.inr b₂ => False.elim (by sorry)
              ))
            ((·.val.snd) : { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } → Y₁)
          ) 0 0
          (A₂.submatrix
            (((·.val.snd) : { x₂ : Fin k × X₂ // f x₂.fst = Sum.inr x₂.snd } → X₂) ∘ (
              fun z =>
                match hfg : f z.val.fst with
                | Sum.inl b₁ => False.elim (by sorry)
                | Sum.inr b₂ => ⟨⟨z.val.fst, b₂⟩, hfg⟩
              ))
            ((·.val.snd) : { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } → Y₂)
          ))
      · ext i j
        cases i <;> cases j <;> sorry
      have hAfg'''' :
        (Matrix.fromBlocks
          (A₁.submatrix
            (((·.val.snd) : { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd } → X₁) ∘ (
              fun z : { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } =>
                match hfg : f z.val.fst with
                | Sum.inl b₁ => ⟨⟨z.val.fst, b₁⟩, hfg⟩
                | Sum.inr b₂ => False.elim (by sorry)
              ))
            ((·.val.snd) : { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } → Y₁)
          ) 0 0
          (A₂.submatrix
            (((·.val.snd) : { x₂ : Fin k × X₂ // f x₂.fst = Sum.inr x₂.snd } → X₂) ∘ (
              fun z : { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } =>
                match hfg : f z.val.fst with
                | Sum.inl b₁ => False.elim (by sorry)
                | Sum.inr b₂ => ⟨⟨z.val.fst, b₂⟩, hfg⟩
              ))
            ((·.val.snd) : { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } → Y₂)
          ))
        =
        (Matrix.fromBlocks
          (A₁.submatrix
            (fun y =>
              match hfg : f y.val.fst with
              | Sum.inl x₁ => x₁
              | Sum.inr x₂ => False.elim (by sorry)
            )
            ((·.val.snd) : { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } → Y₁)
          ) 0 0
          (A₂.submatrix
            (fun y =>
              match hfg : f y.val.fst with
              | Sum.inl x₁ => False.elim (by sorry)
              | Sum.inr x₂ => x₂
            )
            ((·.val.snd) : { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } → Y₂)
          ))
      · ext i j
        cases i <;> cases j <;> sorry
      rw [hAfg'', hAfg''', hAfg'''']
      clear hAfg'' hAfg''' hAfg''''
      have rankA₂ :
        (A₂.submatrix
          (fun y : { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } =>
            match hfg : f y.val.fst with
            | Sum.inl x₁ => False.elim (by sorry)
            | Sum.inr x₂ => x₂
          )
          ((·.val.snd) : { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } → Y₂)
        ).rank ≤
          Fintype.card { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd }
      · apply Matrix.rank_le_card_height
      have rank0A₂ :
        (Matrix.fromColumns
          (0 : Matrix _ { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } _)
          (A₂.submatrix
            (fun y : { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } =>
              match hfg : f y.val.fst with
              | Sum.inl x₁ => False.elim (by sorry)
              | Sum.inr x₂ => x₂
            )
            ((·.val.snd) : { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } → Y₂)
          )
        ).rank ≤
          Fintype.card { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd }
      · rwa [Matrix.fromColumns_zero_rank]
      have rankA₁ :
        (A₁.submatrix
          (fun y : { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } =>
            match hfg : f y.val.fst with
            | Sum.inl x₁ => x₁
            | Sum.inr x₂ => False.elim (by sorry)
          )
          ((·.val.snd) : { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } → Y₁)
        ).rank ≤
          Fintype.card { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd }
      · sorry -- TODO this looks sus! Look into this first!
      have rankA₁0 :
        (Matrix.fromColumns
          (A₁.submatrix
            (fun y : { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } =>
              match hfg : f y.val.fst with
              | Sum.inl x₁ => x₁
              | Sum.inr x₂ => False.elim (by sorry)
            )
            ((·.val.snd) : { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } → Y₁)
          )
          (0 : Matrix _ { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } _)
        ).rank ≤
          Fintype.card { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd }
      · sorry -- swap left<->right, then `rwa [Matrix.fromColumns_zero_rank]`
      have rankA₁00A₂ :
        (Matrix.fromRows
          (Matrix.fromColumns
            (A₁.submatrix
              (fun y : { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } =>
                match hfg : f y.val.fst with
                | Sum.inl x₁ => x₁
                | Sum.inr x₂ => False.elim (by sorry)
              )
              ((·.val.snd) : { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } → Y₁)
            )
            (0 : Matrix _ { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } _)
          )
          (Matrix.fromColumns
            (0 : Matrix _ { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } _)
            (A₂.submatrix
              (fun y : { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } =>
                match hfg : f y.val.fst with
                | Sum.inl x₁ => False.elim (by sorry)
                | Sum.inr x₂ => x₂
              )
              ((·.val.snd) : { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd } → Y₂)
            )
          )
        ).rank ≤
          Fintype.card { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd } +
          Fintype.card { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd }
      · trans
        · apply Matrix.fromRows_rank_subadditive
        · exact Nat.add_le_add rankA₁0 rank0A₂
      rw [abs_eq_zero]
      apply Matrix.det_zero_of_rank_lt
      rw [←Matrix.fromRows_fromColumn_eq_fromBlocks]
      apply rankA₁00A₂.trans_lt
      rw [Fintype.card_sum]
      apply Nat.add_lt_add_right hxy₁
    else
      sorry -- the top half of our submatrix does not have maximal rank

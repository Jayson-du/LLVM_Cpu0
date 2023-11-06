; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

declare void @use(i1)

define i1 @PR1817_1(i32 %X) {
; CHECK-LABEL: @PR1817_1(
; CHECK-NEXT:    [[B:%.*]] = icmp ult i32 [[X:%.*]], 10
; CHECK-NEXT:    ret i1 [[B]]
;
  %A = icmp slt i32 %X, 10
  %B = icmp ult i32 %X, 10
  %C = and i1 %A, %B
  ret i1 %C
}

define i1 @PR1817_1_logical(i32 %X) {
; CHECK-LABEL: @PR1817_1_logical(
; CHECK-NEXT:    [[B:%.*]] = icmp ult i32 [[X:%.*]], 10
; CHECK-NEXT:    ret i1 [[B]]
;
  %A = icmp slt i32 %X, 10
  %B = icmp ult i32 %X, 10
  %C = select i1 %A, i1 %B, i1 false
  ret i1 %C
}

define i1 @PR1817_2(i32 %X) {
; CHECK-LABEL: @PR1817_2(
; CHECK-NEXT:    [[A:%.*]] = icmp slt i32 [[X:%.*]], 10
; CHECK-NEXT:    ret i1 [[A]]
;
  %A = icmp slt i32 %X, 10
  %B = icmp ult i32 %X, 10
  %C = or i1 %A, %B
  ret i1 %C
}

define i1 @PR1817_2_logical(i32 %X) {
; CHECK-LABEL: @PR1817_2_logical(
; CHECK-NEXT:    [[A:%.*]] = icmp slt i32 [[X:%.*]], 10
; CHECK-NEXT:    ret i1 [[A]]
;
  %A = icmp slt i32 %X, 10
  %B = icmp ult i32 %X, 10
  %C = select i1 %A, i1 true, i1 %B
  ret i1 %C
}

define i1 @PR2330(i32 %a, i32 %b) {
; CHECK-LABEL: @PR2330(
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[B:%.*]], [[A:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ult i32 [[TMP1]], 8
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp ult i32 %a, 8
  %cmp2 = icmp ult i32 %b, 8
  %and = and i1 %cmp2, %cmp1
  ret i1 %and
}

define i1 @PR2330_logical(i32 %a, i32 %b) {
; CHECK-LABEL: @PR2330_logical(
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[B:%.*]], [[A:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ult i32 [[TMP1]], 8
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp ult i32 %a, 8
  %cmp2 = icmp ult i32 %b, 8
  %and = select i1 %cmp2, i1 %cmp1, i1 false
  ret i1 %and
}

; if LHSC and RHSC differ only by one bit:
; (X == C1 || X == C2) -> (X & ~(C1 ^ C2)) == C1 (C1 has 1 less set bit)
; PR14708: https://bugs.llvm.org/show_bug.cgi?id=14708

define i1 @or_eq_with_one_bit_diff_constants1(i32 %x) {
; CHECK-LABEL: @or_eq_with_one_bit_diff_constants1(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[X:%.*]], -2
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 50
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp eq i32 %x, 50
  %cmp2 = icmp eq i32 %x, 51
  %or = or i1 %cmp1, %cmp2
  ret i1 %or
}

define i1 @or_eq_with_one_bit_diff_constants1_logical(i32 %x) {
; CHECK-LABEL: @or_eq_with_one_bit_diff_constants1_logical(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[X:%.*]], -2
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 50
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp eq i32 %x, 50
  %cmp2 = icmp eq i32 %x, 51
  %or = select i1 %cmp1, i1 true, i1 %cmp2
  ret i1 %or
}

; (X != C1 && X != C2) -> (X & ~(C1 ^ C2)) != C1 (C1 has 1 less set bit)

define i1 @and_ne_with_one_bit_diff_constants1(i32 %x) {
; CHECK-LABEL: @and_ne_with_one_bit_diff_constants1(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[X:%.*]], -2
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i32 [[TMP1]], 50
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp ne i32 %x, 51
  %cmp2 = icmp ne i32 %x, 50
  %and = and i1 %cmp1, %cmp2
  ret i1 %and
}

define i1 @and_ne_with_one_bit_diff_constants1_logical(i32 %x) {
; CHECK-LABEL: @and_ne_with_one_bit_diff_constants1_logical(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[X:%.*]], -2
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i32 [[TMP1]], 50
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp ne i32 %x, 51
  %cmp2 = icmp ne i32 %x, 50
  %and = select i1 %cmp1, i1 %cmp2, i1 false
  ret i1 %and
}

; The constants are not necessarily off-by-one, just off-by-one-bit.

define i1 @or_eq_with_one_bit_diff_constants2(i32 %x) {
; CHECK-LABEL: @or_eq_with_one_bit_diff_constants2(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[X:%.*]], -33
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 65
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp eq i32 %x, 97
  %cmp2 = icmp eq i32 %x, 65
  %or = or i1 %cmp1, %cmp2
  ret i1 %or
}

define i1 @or_eq_with_one_bit_diff_constants2_logical(i32 %x) {
; CHECK-LABEL: @or_eq_with_one_bit_diff_constants2_logical(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[X:%.*]], -33
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 65
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp eq i32 %x, 97
  %cmp2 = icmp eq i32 %x, 65
  %or = select i1 %cmp1, i1 true, i1 %cmp2
  ret i1 %or
}

define i1 @and_ne_with_one_bit_diff_constants2(i19 %x) {
; CHECK-LABEL: @and_ne_with_one_bit_diff_constants2(
; CHECK-NEXT:    [[TMP1:%.*]] = and i19 [[X:%.*]], -129
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i19 [[TMP1]], 65
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp ne i19 %x, 65
  %cmp2 = icmp ne i19 %x, 193
  %and = and i1 %cmp1, %cmp2
  ret i1 %and
}

define i1 @and_ne_with_one_bit_diff_constants2_logical(i19 %x) {
; CHECK-LABEL: @and_ne_with_one_bit_diff_constants2_logical(
; CHECK-NEXT:    [[TMP1:%.*]] = and i19 [[X:%.*]], -129
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i19 [[TMP1]], 65
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp ne i19 %x, 65
  %cmp2 = icmp ne i19 %x, 193
  %and = select i1 %cmp1, i1 %cmp2, i1 false
  ret i1 %and
}

; Make sure the constants are treated as unsigned when comparing them.

define i1 @or_eq_with_one_bit_diff_constants3(i8 %x) {
; CHECK-LABEL: @or_eq_with_one_bit_diff_constants3(
; CHECK-NEXT:    [[TMP1:%.*]] = and i8 [[X:%.*]], 127
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i8 [[TMP1]], 126
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp eq i8 %x, 254
  %cmp2 = icmp eq i8 %x, 126
  %or = or i1 %cmp1, %cmp2
  ret i1 %or
}

define i1 @or_eq_with_one_bit_diff_constants3_logical(i8 %x) {
; CHECK-LABEL: @or_eq_with_one_bit_diff_constants3_logical(
; CHECK-NEXT:    [[TMP1:%.*]] = and i8 [[X:%.*]], 127
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i8 [[TMP1]], 126
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp eq i8 %x, 254
  %cmp2 = icmp eq i8 %x, 126
  %or = select i1 %cmp1, i1 true, i1 %cmp2
  ret i1 %or
}

define i1 @and_ne_with_one_bit_diff_constants3(i8 %x) {
; CHECK-LABEL: @and_ne_with_one_bit_diff_constants3(
; CHECK-NEXT:    [[TMP1:%.*]] = and i8 [[X:%.*]], 127
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i8 [[TMP1]], 65
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp ne i8 %x, 65
  %cmp2 = icmp ne i8 %x, 193
  %and = and i1 %cmp1, %cmp2
  ret i1 %and
}

define i1 @and_ne_with_one_bit_diff_constants3_logical(i8 %x) {
; CHECK-LABEL: @and_ne_with_one_bit_diff_constants3_logical(
; CHECK-NEXT:    [[TMP1:%.*]] = and i8 [[X:%.*]], 127
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i8 [[TMP1]], 65
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp ne i8 %x, 65
  %cmp2 = icmp ne i8 %x, 193
  %and = select i1 %cmp1, i1 %cmp2, i1 false
  ret i1 %and
}

; Use an 'add' to eliminate an icmp if the constants are off-by-one (not off-by-one-bit).
; (X == 13 | X == 14) -> X-13 <u 2

define i1 @or_eq_with_diff_one(i8 %x) {
; CHECK-LABEL: @or_eq_with_diff_one(
; CHECK-NEXT:    [[TMP1:%.*]] = add i8 [[X:%.*]], -13
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ult i8 [[TMP1]], 2
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp eq i8 %x, 13
  %cmp2 = icmp eq i8 %x, 14
  %or = or i1 %cmp1, %cmp2
  ret i1 %or
}

define i1 @or_eq_with_diff_one_logical(i8 %x) {
; CHECK-LABEL: @or_eq_with_diff_one_logical(
; CHECK-NEXT:    [[TMP1:%.*]] = add i8 [[X:%.*]], -13
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ult i8 [[TMP1]], 2
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp eq i8 %x, 13
  %cmp2 = icmp eq i8 %x, 14
  %or = select i1 %cmp1, i1 true, i1 %cmp2
  ret i1 %or
}

; (X != 40 | X != 39) -> X-39 >u 1

define i1 @and_ne_with_diff_one(i32 %x) {
; CHECK-LABEL: @and_ne_with_diff_one(
; CHECK-NEXT:    [[TMP1:%.*]] = add i32 [[X:%.*]], -39
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ugt i32 [[TMP1]], 1
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp ne i32 %x, 40
  %cmp2 = icmp ne i32 %x, 39
  %and = and i1 %cmp1, %cmp2
  ret i1 %and
}

define i1 @and_ne_with_diff_one_logical(i32 %x) {
; CHECK-LABEL: @and_ne_with_diff_one_logical(
; CHECK-NEXT:    [[TMP1:%.*]] = add i32 [[X:%.*]], -39
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ugt i32 [[TMP1]], 1
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp ne i32 %x, 40
  %cmp2 = icmp ne i32 %x, 39
  %and = select i1 %cmp1, i1 %cmp2, i1 false
  ret i1 %and
}

; Make sure the constants are treated as signed when comparing them.
; PR32524: https://bugs.llvm.org/show_bug.cgi?id=32524

define i1 @or_eq_with_diff_one_signed(i32 %x) {
; CHECK-LABEL: @or_eq_with_diff_one_signed(
; CHECK-NEXT:    [[TMP1:%.*]] = add i32 [[X:%.*]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ult i32 [[TMP1]], 2
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp eq i32 %x, 0
  %cmp2 = icmp eq i32 %x, -1
  %or = or i1 %cmp1, %cmp2
  ret i1 %or
}

define i1 @or_eq_with_diff_one_signed_logical(i32 %x) {
; CHECK-LABEL: @or_eq_with_diff_one_signed_logical(
; CHECK-NEXT:    [[TMP1:%.*]] = add i32 [[X:%.*]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ult i32 [[TMP1]], 2
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp eq i32 %x, 0
  %cmp2 = icmp eq i32 %x, -1
  %or = select i1 %cmp1, i1 true, i1 %cmp2
  ret i1 %or
}

define i1 @and_ne_with_diff_one_signed(i64 %x) {
; CHECK-LABEL: @and_ne_with_diff_one_signed(
; CHECK-NEXT:    [[TMP1:%.*]] = add i64 [[X:%.*]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ugt i64 [[TMP1]], 1
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp ne i64 %x, -1
  %cmp2 = icmp ne i64 %x, 0
  %and = and i1 %cmp1, %cmp2
  ret i1 %and
}

define i1 @and_ne_with_diff_one_signed_logical(i64 %x) {
; CHECK-LABEL: @and_ne_with_diff_one_signed_logical(
; CHECK-NEXT:    [[TMP1:%.*]] = add i64 [[X:%.*]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ugt i64 [[TMP1]], 1
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp ne i64 %x, -1
  %cmp2 = icmp ne i64 %x, 0
  %and = select i1 %cmp1, i1 %cmp2, i1 false
  ret i1 %and
}

; Vectors with splat constants get the same folds.

define <2 x i1> @or_eq_with_one_bit_diff_constants2_splatvec(<2 x i32> %x) {
; CHECK-LABEL: @or_eq_with_one_bit_diff_constants2_splatvec(
; CHECK-NEXT:    [[TMP1:%.*]] = and <2 x i32> [[X:%.*]], <i32 -33, i32 -33>
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq <2 x i32> [[TMP1]], <i32 65, i32 65>
; CHECK-NEXT:    ret <2 x i1> [[TMP2]]
;
  %cmp1 = icmp eq <2 x i32> %x, <i32 97, i32 97>
  %cmp2 = icmp eq <2 x i32> %x, <i32 65, i32 65>
  %or = or <2 x i1> %cmp1, %cmp2
  ret <2 x i1> %or
}

define <2 x i1> @and_ne_with_diff_one_splatvec(<2 x i32> %x) {
; CHECK-LABEL: @and_ne_with_diff_one_splatvec(
; CHECK-NEXT:    [[TMP1:%.*]] = add <2 x i32> [[X:%.*]], <i32 -39, i32 -39>
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ugt <2 x i32> [[TMP1]], <i32 1, i32 1>
; CHECK-NEXT:    ret <2 x i1> [[TMP2]]
;
  %cmp1 = icmp ne <2 x i32> %x, <i32 40, i32 40>
  %cmp2 = icmp ne <2 x i32> %x, <i32 39, i32 39>
  %and = and <2 x i1> %cmp1, %cmp2
  ret <2 x i1> %and
}

; This is a fuzzer-generated test that would assert because
; we'd get into foldAndOfICmps() without running InstSimplify
; on an 'and' that should have been killed. It's not obvious
; why, but removing anything hides the bug, hence the long test.

define void @simplify_before_foldAndOfICmps() {
; CHECK-LABEL: @simplify_before_foldAndOfICmps(
; CHECK-NEXT:    [[A8:%.*]] = alloca i16, align 2
; CHECK-NEXT:    [[L7:%.*]] = load i16, i16* [[A8]], align 2
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i16 [[L7]], -1
; CHECK-NEXT:    [[B11:%.*]] = zext i1 [[TMP1]] to i16
; CHECK-NEXT:    [[C10:%.*]] = icmp ugt i16 [[L7]], [[B11]]
; CHECK-NEXT:    [[C5:%.*]] = icmp slt i16 [[L7]], 1
; CHECK-NEXT:    [[C11:%.*]] = icmp ne i16 [[L7]], 0
; CHECK-NEXT:    [[C7:%.*]] = icmp slt i16 [[L7]], 0
; CHECK-NEXT:    [[B15:%.*]] = xor i1 [[C7]], [[C10]]
; CHECK-NEXT:    [[B19:%.*]] = xor i1 [[C11]], [[B15]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i1 [[C10]], [[C5]]
; CHECK-NEXT:    [[C3:%.*]] = and i1 [[TMP2]], [[B19]]
; CHECK-NEXT:    [[TMP3:%.*]] = xor i1 [[C10]], true
; CHECK-NEXT:    [[C18:%.*]] = or i1 [[C7]], [[TMP3]]
; CHECK-NEXT:    [[TMP4:%.*]] = sext i1 [[C3]] to i64
; CHECK-NEXT:    [[G26:%.*]] = getelementptr i1, i1* null, i64 [[TMP4]]
; CHECK-NEXT:    store i16 [[L7]], i16* undef, align 2
; CHECK-NEXT:    store i1 [[C18]], i1* undef, align 1
; CHECK-NEXT:    store i1* [[G26]], i1** undef, align 8
; CHECK-NEXT:    ret void
;
  %A8 = alloca i16
  %L7 = load i16, i16* %A8
  %G21 = getelementptr i16, i16* %A8, i8 -1
  %B11 = udiv i16 %L7, -1
  %G4 = getelementptr i16, i16* %A8, i16 %B11
  %L2 = load i16, i16* %G4
  %L = load i16, i16* %G4
  %B23 = mul i16 %B11, %B11
  %L4 = load i16, i16* %A8
  %B21 = sdiv i16 %L7, %L4
  %B7 = sub i16 0, %B21
  %B18 = mul i16 %B23, %B7
  %C10 = icmp ugt i16 %L, %B11
  %B20 = and i16 %L7, %L2
  %B1 = mul i1 %C10, true
  %C5 = icmp sle i16 %B21, %L
  %C11 = icmp ule i16 %B21, %L
  %C7 = icmp slt i16 %B20, 0
  %B29 = srem i16 %L4, %B18
  %B15 = add i1 %C7, %C10
  %B19 = add i1 %C11, %B15
  %C6 = icmp sge i1 %C11, %B19
  %B33 = or i16 %B29, %L4
  %C13 = icmp uge i1 %C5, %B1
  %C3 = icmp ult i1 %C13, %C6
  store i16 undef, i16* %G21
  %C18 = icmp ule i1 %C10, %C7
  %G26 = getelementptr i1, i1* null, i1 %C3
  store i16 %B33, i16* undef
  store i1 %C18, i1* undef
  store i1* %G26, i1** undef
  ret void
}

define i1 @PR42691_1(i32 %x) {
; CHECK-LABEL: @PR42691_1(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ugt i32 [[X:%.*]], 2147483646
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp slt i32 %x, 0
  %c2 = icmp eq i32 %x, 2147483647
  %c = or i1 %c1, %c2
  ret i1 %c
}

define i1 @PR42691_1_logical(i32 %x) {
; CHECK-LABEL: @PR42691_1_logical(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ugt i32 [[X:%.*]], 2147483646
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp slt i32 %x, 0
  %c2 = icmp eq i32 %x, 2147483647
  %c = select i1 %c1, i1 true, i1 %c2
  ret i1 %c
}

define i1 @PR42691_2(i32 %x) {
; CHECK-LABEL: @PR42691_2(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i32 [[X:%.*]], -2
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp ult i32 %x, 2147483648
  %c2 = icmp eq i32 %x, 4294967295
  %c = or i1 %c1, %c2
  ret i1 %c
}

define i1 @PR42691_2_logical(i32 %x) {
; CHECK-LABEL: @PR42691_2_logical(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i32 [[X:%.*]], -2
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp ult i32 %x, 2147483648
  %c2 = icmp eq i32 %x, 4294967295
  %c = select i1 %c1, i1 true, i1 %c2
  ret i1 %c
}

define i1 @PR42691_3(i32 %x) {
; CHECK-LABEL: @PR42691_3(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[X:%.*]], -2147483647
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp sge i32 %x, 0
  %c2 = icmp eq i32 %x, -2147483648
  %c = or i1 %c1, %c2
  ret i1 %c
}

define i1 @PR42691_3_logical(i32 %x) {
; CHECK-LABEL: @PR42691_3_logical(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[X:%.*]], -2147483647
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp sge i32 %x, 0
  %c2 = icmp eq i32 %x, -2147483648
  %c = select i1 %c1, i1 true, i1 %c2
  ret i1 %c
}

define i1 @PR42691_4(i32 %x) {
; CHECK-LABEL: @PR42691_4(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 [[X:%.*]], 1
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp uge i32 %x, 2147483648
  %c2 = icmp eq i32 %x, 0
  %c = or i1 %c1, %c2
  ret i1 %c
}

define i1 @PR42691_4_logical(i32 %x) {
; CHECK-LABEL: @PR42691_4_logical(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 [[X:%.*]], 1
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp uge i32 %x, 2147483648
  %c2 = icmp eq i32 %x, 0
  %c = select i1 %c1, i1 true, i1 %c2
  ret i1 %c
}

define i1 @PR42691_5(i32 %x) {
; CHECK-LABEL: @PR42691_5(
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 [[X:%.*]], -1
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ugt i32 [[X_OFF]], 2147483645
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp slt i32 %x, 1
  %c2 = icmp eq i32 %x, 2147483647
  %c = or i1 %c1, %c2
  ret i1 %c
}

define i1 @PR42691_5_logical(i32 %x) {
; CHECK-LABEL: @PR42691_5_logical(
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 [[X:%.*]], -1
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ugt i32 [[X_OFF]], 2147483645
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp slt i32 %x, 1
  %c2 = icmp eq i32 %x, 2147483647
  %c = select i1 %c1, i1 true, i1 %c2
  ret i1 %c
}

define i1 @PR42691_6(i32 %x) {
; CHECK-LABEL: @PR42691_6(
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 [[X:%.*]], 2147483647
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ugt i32 [[X_OFF]], 2147483645
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp ult i32 %x, 2147483649
  %c2 = icmp eq i32 %x, 4294967295
  %c = or i1 %c1, %c2
  ret i1 %c
}

define i1 @PR42691_6_logical(i32 %x) {
; CHECK-LABEL: @PR42691_6_logical(
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 [[X:%.*]], 2147483647
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ugt i32 [[X_OFF]], 2147483645
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp ult i32 %x, 2147483649
  %c2 = icmp eq i32 %x, 4294967295
  %c = select i1 %c1, i1 true, i1 %c2
  ret i1 %c
}

define i1 @PR42691_7(i32 %x) {
; CHECK-LABEL: @PR42691_7(
; CHECK-NEXT:    [[TMP1:%.*]] = add i32 [[X:%.*]], -1
; CHECK-NEXT:    [[TMP2:%.*]] = icmp slt i32 [[TMP1]], 0
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %c1 = icmp uge i32 %x, 2147483649
  %c2 = icmp eq i32 %x, 0
  %c = or i1 %c1, %c2
  ret i1 %c
}

define i1 @PR42691_7_logical(i32 %x) {
; CHECK-LABEL: @PR42691_7_logical(
; CHECK-NEXT:    [[TMP1:%.*]] = add i32 [[X:%.*]], -1
; CHECK-NEXT:    [[TMP2:%.*]] = icmp slt i32 [[TMP1]], 0
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %c1 = icmp uge i32 %x, 2147483649
  %c2 = icmp eq i32 %x, 0
  %c = select i1 %c1, i1 true, i1 %c2
  ret i1 %c
}

define i1 @PR42691_8(i32 %x) {
; CHECK-LABEL: @PR42691_8(
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 [[X:%.*]], 2147483647
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[X_OFF]], -2147483635
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp slt i32 %x, 14
  %c2 = icmp ne i32 %x, -2147483648
  %c = and i1 %c1, %c2
  ret i1 %c
}

define i1 @PR42691_8_logical(i32 %x) {
; CHECK-LABEL: @PR42691_8_logical(
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 [[X:%.*]], 2147483647
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[X_OFF]], -2147483635
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp slt i32 %x, 14
  %c2 = icmp ne i32 %x, -2147483648
  %c = select i1 %c1, i1 %c2, i1 false
  ret i1 %c
}

define i1 @PR42691_9(i32 %x) {
; CHECK-LABEL: @PR42691_9(
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 [[X:%.*]], -14
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[X_OFF]], 2147483633
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp sgt i32 %x, 13
  %c2 = icmp ne i32 %x, 2147483647
  %c = and i1 %c1, %c2
  ret i1 %c
}

define i1 @PR42691_9_logical(i32 %x) {
; CHECK-LABEL: @PR42691_9_logical(
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 [[X:%.*]], -14
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[X_OFF]], 2147483633
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp sgt i32 %x, 13
  %c2 = icmp ne i32 %x, 2147483647
  %c = select i1 %c1, i1 %c2, i1 false
  ret i1 %c
}

define i1 @PR42691_10(i32 %x) {
; CHECK-LABEL: @PR42691_10(
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 [[X:%.*]], -14
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[X_OFF]], -15
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp ugt i32 %x, 13
  %c2 = icmp ne i32 %x, 4294967295
  %c = and i1 %c1, %c2
  ret i1 %c
}

define i1 @PR42691_10_logical(i32 %x) {
; CHECK-LABEL: @PR42691_10_logical(
; CHECK-NEXT:    [[X_OFF:%.*]] = add i32 [[X:%.*]], -14
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[X_OFF]], -15
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %c1 = icmp ugt i32 %x, 13
  %c2 = icmp ne i32 %x, 4294967295
  %c = select i1 %c1, i1 %c2, i1 false
  ret i1 %c
}

define i1 @substitute_constant_and_eq_eq(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_and_eq_eq(
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[X:%.*]], 42
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[Y:%.*]], 42
; CHECK-NEXT:    [[TMP2:%.*]] = and i1 [[C1]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %c1 = icmp eq i8 %x, 42
  %c2 = icmp eq i8 %x, %y
  %r = and i1 %c1, %c2
  ret i1 %r
}

define i1 @substitute_constant_and_eq_eq_logical(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_and_eq_eq_logical(
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[X:%.*]], 42
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[Y:%.*]], 42
; CHECK-NEXT:    [[TMP2:%.*]] = and i1 [[C1]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %c1 = icmp eq i8 %x, 42
  %c2 = icmp eq i8 %x, %y
  %r = select i1 %c1, i1 %c2, i1 false
  ret i1 %r
}

define i1 @substitute_constant_and_eq_eq_commute(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_and_eq_eq_commute(
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[X:%.*]], 42
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[Y:%.*]], 42
; CHECK-NEXT:    [[TMP2:%.*]] = and i1 [[C1]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %c1 = icmp eq i8 %x, 42
  %c2 = icmp eq i8 %x, %y
  %r = and i1 %c2, %c1
  ret i1 %r
}

define i1 @substitute_constant_and_eq_eq_commute_logical(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_and_eq_eq_commute_logical(
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[X:%.*]], 42
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i8 [[Y:%.*]], 42
; CHECK-NEXT:    [[TMP2:%.*]] = and i1 [[C1]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %c1 = icmp eq i8 %x, 42
  %c2 = icmp eq i8 %x, %y
  %r = select i1 %c2, i1 %c1, i1 false
  ret i1 %r
}

define i1 @substitute_constant_and_eq_ugt_swap(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_and_eq_ugt_swap(
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[X:%.*]], 42
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ugt i8 [[Y:%.*]], 42
; CHECK-NEXT:    [[TMP2:%.*]] = and i1 [[C1]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %c1 = icmp eq i8 %x, 42
  %c2 = icmp ugt i8 %y, %x
  %r = and i1 %c2, %c1
  ret i1 %r
}

define i1 @substitute_constant_and_eq_ugt_swap_logical(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_and_eq_ugt_swap_logical(
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[X:%.*]], 42
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ugt i8 [[Y:%.*]], 42
; CHECK-NEXT:    [[TMP2:%.*]] = and i1 [[C1]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %c1 = icmp eq i8 %x, 42
  %c2 = icmp ugt i8 %y, %x
  %r = select i1 %c2, i1 %c1, i1 false
  ret i1 %r
}

define <2 x i1> @substitute_constant_and_eq_ne_vec(<2 x i8> %x, <2 x i8> %y) {
; CHECK-LABEL: @substitute_constant_and_eq_ne_vec(
; CHECK-NEXT:    [[C1:%.*]] = icmp eq <2 x i8> [[X:%.*]], <i8 42, i8 97>
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ne <2 x i8> [[Y:%.*]], <i8 42, i8 97>
; CHECK-NEXT:    [[TMP2:%.*]] = and <2 x i1> [[C1]], [[TMP1]]
; CHECK-NEXT:    ret <2 x i1> [[TMP2]]
;
  %c1 = icmp eq <2 x i8> %x, <i8 42, i8 97>
  %c2 = icmp ne <2 x i8> %x, %y
  %r = and <2 x i1> %c1, %c2
  ret <2 x i1> %r
}

define i1 @substitute_constant_and_eq_sgt_use(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_and_eq_sgt_use(
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[X:%.*]], 42
; CHECK-NEXT:    call void @use(i1 [[C1]])
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i8 [[Y:%.*]], 42
; CHECK-NEXT:    [[TMP2:%.*]] = and i1 [[C1]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %c1 = icmp eq i8 %x, 42
  call void @use(i1 %c1)
  %c2 = icmp sgt i8 %x, %y
  %r = and i1 %c2, %c1
  ret i1 %r
}

define i1 @substitute_constant_and_eq_sgt_use_logical(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_and_eq_sgt_use_logical(
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[X:%.*]], 42
; CHECK-NEXT:    call void @use(i1 [[C1]])
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i8 [[Y:%.*]], 42
; CHECK-NEXT:    [[TMP2:%.*]] = and i1 [[C1]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %c1 = icmp eq i8 %x, 42
  call void @use(i1 %c1)
  %c2 = icmp sgt i8 %x, %y
  %r = select i1 %c2, i1 %c1, i1 false
  ret i1 %r
}

; Negative test - extra use

define i1 @substitute_constant_and_eq_sgt_use2(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_and_eq_sgt_use2(
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[X:%.*]], 42
; CHECK-NEXT:    [[C2:%.*]] = icmp sgt i8 [[X]], [[Y:%.*]]
; CHECK-NEXT:    call void @use(i1 [[C2]])
; CHECK-NEXT:    [[R:%.*]] = and i1 [[C2]], [[C1]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %c1 = icmp eq i8 %x, 42
  %c2 = icmp sgt i8 %x, %y
  call void @use(i1 %c2)
  %r = and i1 %c2, %c1
  ret i1 %r
}

define i1 @substitute_constant_and_eq_sgt_use2_logical(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_and_eq_sgt_use2_logical(
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[X:%.*]], 42
; CHECK-NEXT:    [[C2:%.*]] = icmp sgt i8 [[X]], [[Y:%.*]]
; CHECK-NEXT:    call void @use(i1 [[C2]])
; CHECK-NEXT:    [[R:%.*]] = and i1 [[C2]], [[C1]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %c1 = icmp eq i8 %x, 42
  %c2 = icmp sgt i8 %x, %y
  call void @use(i1 %c2)
  %r = select i1 %c2, i1 %c1, i1 false
  ret i1 %r
}

; Extra use does not prevent transform if the expression simplifies:
; X == MAX && X < Y --> false

define i1 @slt_and_max(i8 %x, i8 %y)  {
; CHECK-LABEL: @slt_and_max(
; CHECK-NEXT:    [[C2:%.*]] = icmp slt i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    call void @use(i1 [[C2]])
; CHECK-NEXT:    ret i1 false
;
  %c1 = icmp eq i8 %x, 127
  %c2 = icmp slt i8 %x, %y
  call void @use(i1 %c2)
  %r = and i1 %c2, %c1
  ret i1 %r
}

define i1 @slt_and_max_logical(i8 %x, i8 %y)  {
; CHECK-LABEL: @slt_and_max_logical(
; CHECK-NEXT:    [[C2:%.*]] = icmp slt i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    call void @use(i1 [[C2]])
; CHECK-NEXT:    ret i1 false
;
  %c1 = icmp eq i8 %x, 127
  %c2 = icmp slt i8 %x, %y
  call void @use(i1 %c2)
  %r = select i1 %c2, i1 %c1, i1 false
  ret i1 %r
}

; Extra use does not prevent transform if the expression simplifies:
; X == MAX && X >= Y --> X == MAX

define i1 @sge_and_max(i8 %x, i8 %y)  {
; CHECK-LABEL: @sge_and_max(
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[X:%.*]], 127
; CHECK-NEXT:    [[C2:%.*]] = icmp sge i8 [[X]], [[Y:%.*]]
; CHECK-NEXT:    call void @use(i1 [[C2]])
; CHECK-NEXT:    ret i1 [[C1]]
;
  %c1 = icmp eq i8 %x, 127
  %c2 = icmp sge i8 %x, %y
  call void @use(i1 %c2)
  %r = and i1 %c2, %c1
  ret i1 %r
}

define i1 @sge_and_max_logical(i8 %x, i8 %y)  {
; CHECK-LABEL: @sge_and_max_logical(
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[X:%.*]], 127
; CHECK-NEXT:    [[C2:%.*]] = icmp sge i8 [[X]], [[Y:%.*]]
; CHECK-NEXT:    call void @use(i1 [[C2]])
; CHECK-NEXT:    ret i1 [[C1]]
;
  %c1 = icmp eq i8 %x, 127
  %c2 = icmp sge i8 %x, %y
  call void @use(i1 %c2)
  %r = select i1 %c2, i1 %c1, i1 false
  ret i1 %r
}

define i1 @substitute_constant_and_ne_ugt_swap(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_and_ne_ugt_swap(
; CHECK-NEXT:    [[C1:%.*]] = icmp ne i8 [[X:%.*]], 42
; CHECK-NEXT:    [[C2:%.*]] = icmp ugt i8 [[Y:%.*]], [[X]]
; CHECK-NEXT:    [[R:%.*]] = and i1 [[C2]], [[C1]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %c1 = icmp ne i8 %x, 42
  %c2 = icmp ugt i8 %y, %x
  %r = and i1 %c2, %c1
  ret i1 %r
}

define i1 @substitute_constant_and_ne_ugt_swap_logical(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_and_ne_ugt_swap_logical(
; CHECK-NEXT:    [[C1:%.*]] = icmp ne i8 [[X:%.*]], 42
; CHECK-NEXT:    [[C2:%.*]] = icmp ugt i8 [[Y:%.*]], [[X]]
; CHECK-NEXT:    [[R:%.*]] = and i1 [[C2]], [[C1]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %c1 = icmp ne i8 %x, 42
  %c2 = icmp ugt i8 %y, %x
  %r = select i1 %c2, i1 %c1, i1 false
  ret i1 %r
}

define i1 @substitute_constant_or_ne_swap_sle(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_or_ne_swap_sle(
; CHECK-NEXT:    [[C1:%.*]] = icmp ne i8 [[X:%.*]], 42
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i8 [[Y:%.*]], 43
; CHECK-NEXT:    [[TMP2:%.*]] = or i1 [[C1]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %c1 = icmp ne i8 %x, 42
  %c2 = icmp sle i8 %y, %x
  %r = or i1 %c1, %c2
  ret i1 %r
}

define i1 @substitute_constant_or_ne_swap_sle_logical(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_or_ne_swap_sle_logical(
; CHECK-NEXT:    [[C1:%.*]] = icmp ne i8 [[X:%.*]], 42
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i8 [[Y:%.*]], 43
; CHECK-NEXT:    [[TMP2:%.*]] = or i1 [[C1]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %c1 = icmp ne i8 %x, 42
  %c2 = icmp sle i8 %y, %x
  %r = select i1 %c1, i1 true, i1 %c2
  ret i1 %r
}

define i1 @substitute_constant_or_ne_uge_commute(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_or_ne_uge_commute(
; CHECK-NEXT:    [[C1:%.*]] = icmp ne i8 [[X:%.*]], 42
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i8 [[Y:%.*]], 43
; CHECK-NEXT:    [[TMP2:%.*]] = or i1 [[C1]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %c1 = icmp ne i8 %x, 42
  %c2 = icmp uge i8 %x, %y
  %r = or i1 %c2, %c1
  ret i1 %r
}

define i1 @substitute_constant_or_ne_uge_commute_logical(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_or_ne_uge_commute_logical(
; CHECK-NEXT:    [[C1:%.*]] = icmp ne i8 [[X:%.*]], 42
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i8 [[Y:%.*]], 43
; CHECK-NEXT:    [[TMP2:%.*]] = or i1 [[C1]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %c1 = icmp ne i8 %x, 42
  %c2 = icmp uge i8 %x, %y
  %r = select i1 %c2, i1 true, i1 %c1
  ret i1 %r
}

; Negative test - not safe to substitute vector constant with undef element

define <2 x i1> @substitute_constant_or_ne_slt_swap_vec(<2 x i8> %x, <2 x i8> %y) {
; CHECK-LABEL: @substitute_constant_or_ne_slt_swap_vec(
; CHECK-NEXT:    [[C1:%.*]] = icmp ne <2 x i8> [[X:%.*]], <i8 42, i8 undef>
; CHECK-NEXT:    [[C2:%.*]] = icmp slt <2 x i8> [[Y:%.*]], [[X]]
; CHECK-NEXT:    [[R:%.*]] = or <2 x i1> [[C1]], [[C2]]
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %c1 = icmp ne <2 x i8> %x, <i8 42, i8 undef>
  %c2 = icmp slt <2 x i8> %y, %x
  %r = or <2 x i1> %c1, %c2
  ret <2 x i1> %r
}

define i1 @substitute_constant_or_eq_swap_ne(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_or_eq_swap_ne(
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[X:%.*]], 42
; CHECK-NEXT:    [[C2:%.*]] = icmp ne i8 [[Y:%.*]], [[X]]
; CHECK-NEXT:    [[R:%.*]] = or i1 [[C1]], [[C2]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %c1 = icmp eq i8 %x, 42
  %c2 = icmp ne i8 %y, %x
  %r = or i1 %c1, %c2
  ret i1 %r
}

define i1 @substitute_constant_or_eq_swap_ne_logical(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_or_eq_swap_ne_logical(
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i8 [[X:%.*]], 42
; CHECK-NEXT:    [[C2:%.*]] = icmp ne i8 [[Y:%.*]], [[X]]
; CHECK-NEXT:    [[R:%.*]] = or i1 [[C1]], [[C2]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %c1 = icmp eq i8 %x, 42
  %c2 = icmp ne i8 %y, %x
  %r = select i1 %c1, i1 true, i1 %c2
  ret i1 %r
}

define i1 @substitute_constant_or_ne_sge_use(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_or_ne_sge_use(
; CHECK-NEXT:    [[C1:%.*]] = icmp ne i8 [[X:%.*]], 42
; CHECK-NEXT:    call void @use(i1 [[C1]])
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i8 [[Y:%.*]], 43
; CHECK-NEXT:    [[TMP2:%.*]] = or i1 [[C1]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %c1 = icmp ne i8 %x, 42
  call void @use(i1 %c1)
  %c2 = icmp sge i8 %x, %y
  %r = or i1 %c2, %c1
  ret i1 %r
}

define i1 @substitute_constant_or_ne_sge_use_logical(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_or_ne_sge_use_logical(
; CHECK-NEXT:    [[C1:%.*]] = icmp ne i8 [[X:%.*]], 42
; CHECK-NEXT:    call void @use(i1 [[C1]])
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i8 [[Y:%.*]], 43
; CHECK-NEXT:    [[TMP2:%.*]] = or i1 [[C1]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %c1 = icmp ne i8 %x, 42
  call void @use(i1 %c1)
  %c2 = icmp sge i8 %x, %y
  %r = select i1 %c2, i1 true, i1 %c1
  ret i1 %r
}

; Negative test - extra use

define i1 @substitute_constant_or_ne_ule_use2(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_or_ne_ule_use2(
; CHECK-NEXT:    [[C1:%.*]] = icmp ne i8 [[X:%.*]], 42
; CHECK-NEXT:    [[C2:%.*]] = icmp ule i8 [[X]], [[Y:%.*]]
; CHECK-NEXT:    call void @use(i1 [[C2]])
; CHECK-NEXT:    [[R:%.*]] = or i1 [[C2]], [[C1]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %c1 = icmp ne i8 %x, 42
  %c2 = icmp ule i8 %x, %y
  call void @use(i1 %c2)
  %r = or i1 %c2, %c1
  ret i1 %r
}

define i1 @substitute_constant_or_ne_ule_use2_logical(i8 %x, i8 %y) {
; CHECK-LABEL: @substitute_constant_or_ne_ule_use2_logical(
; CHECK-NEXT:    [[C1:%.*]] = icmp ne i8 [[X:%.*]], 42
; CHECK-NEXT:    [[C2:%.*]] = icmp ule i8 [[X]], [[Y:%.*]]
; CHECK-NEXT:    call void @use(i1 [[C2]])
; CHECK-NEXT:    [[R:%.*]] = or i1 [[C2]], [[C1]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %c1 = icmp ne i8 %x, 42
  %c2 = icmp ule i8 %x, %y
  call void @use(i1 %c2)
  %r = select i1 %c2, i1 true, i1 %c1
  ret i1 %r
}

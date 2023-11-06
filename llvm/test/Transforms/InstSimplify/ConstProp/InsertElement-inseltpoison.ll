; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instsimplify -S | FileCheck %s

define i32 @test1() {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    ret i32 2139171423
;
  %A = bitcast i32 2139171423 to float
  %B = insertelement <1 x float> poison, float %A, i32 0
  %C = extractelement <1 x float> %B, i32 0
  %D = bitcast float %C to i32
  ret i32 %D
}

define <4 x i64> @insertelement() {
; CHECK-LABEL: @insertelement(
; CHECK-NEXT:    ret <4 x i64> <i64 -1, i64 -2, i64 -3, i64 -4>
;
  %vec1 = insertelement <4 x i64> poison, i64 -1, i32 0
  %vec2 = insertelement <4 x i64> %vec1, i64 -2, i32 1
  %vec3 = insertelement <4 x i64> %vec2, i64 -3, i32 2
  %vec4 = insertelement <4 x i64> %vec3, i64 -4, i32 3
  ret <4 x i64> %vec4
}

define <4 x i64> @insertelement_undef() {
; CHECK-LABEL: @insertelement_undef(
; CHECK-NEXT:    ret <4 x i64> undef
;
  %vec1 = insertelement <4 x i64> poison, i64 -1, i32 0
  %vec2 = insertelement <4 x i64> %vec1, i64 -2, i32 1
  %vec3 = insertelement <4 x i64> %vec2, i64 -3, i32 2
  %vec4 = insertelement <4 x i64> %vec3, i64 -4, i32 3
  %vec5 = insertelement <4 x i64> %vec3, i64 -5, i32 4
  ret <4 x i64> %vec5
}

define i64 @extract_undef_index_from_zero_vec() {
; CHECK-LABEL: @extract_undef_index_from_zero_vec(
; CHECK-NEXT:    ret i64 poison
;
  %E = extractelement <2 x i64> zeroinitializer, i64 undef
  ret i64 %E
}

define i64 @extract_undef_index_from_nonzero_vec() {
; CHECK-LABEL: @extract_undef_index_from_nonzero_vec(
; CHECK-NEXT:    ret i64 poison
;
  %E = extractelement <2 x i64> <i64 -1, i64 -1>, i64 undef
  ret i64 %E
}

# Master Architecture Gap & Migration Plan

## 적용 원칙

- 기존 `리드 → 상담 → 방문 → 판매 → 회원` Journey를 유지한다.
- 전화번호 컬럼은 어떤 테이블에도 만들지 않는다.
- 회원 상세주소·개인 좌표는 저장하지 않고 `area_id`, `complex_id`, 거리구간만 연결한다.
- 외부 상권 데이터에는 기준일·출처·신뢰등급을 반드시 저장한다.
- 회원수·매출·침투율·공헌이익 같은 계산값은 원천 테이블에 중복 저장하지 않는다.

## 기존 구조에서 유지하는 항목

- 리드, 상담, 방문, 회원, 판매
- 회원권 계약과 재등록 이력
- PT 계약과 PT 수업 분리
- 출석 원천 기록
- 캠페인과 일별 노출
- 경쟁사 가격 Snapshot
- 시장·경영 이벤트
- Soft Delete와 관리자 RLS

## Phase 1 추가 항목

- `areas`: 지역·거리·인구·접근성 Master
- `apartments`: 아파트 단지 Master
- `pois`: 기업·학교·상업시설 등 잠재수요 시설
- `promotions`: 상품별 프로모션 이력
- 회원·리드의 지역 및 아파트 FK
- 상품 변동원가와 계산 View
- 경쟁사 위치·시설·리뷰·신뢰도 필드
- PT 서비스 횟수·계약기간·환불 정보
- 아파트 성과 계산 View

## 의도적으로 저장하지 않는 계산값

- 현재회원, 활성회원, 신규회원, 재등록회원
- 회원권·PT·총매출
- 침투율, 재등록률, PT 전환율
- ARPU, CAC, ROAS
- Opportunity Score
- 공헌이익과 공헌이익률

위 값은 View와 공통 Metrics Layer에서 계산한다. 데이터가 부족한 Score는 산출하지 않는다.

## 다음 Migration

1. Supabase Client와 관리자 인증 연결
2. Phase 1 CRUD를 메모리 어댑터에서 Supabase Repository로 교체
3. 회원·리드 입력에서 지역/아파트 선택 연결
4. Membership·PT·환불 Operational CRM 구현
5. Metrics Layer 및 Area Performance 월별 View 구현

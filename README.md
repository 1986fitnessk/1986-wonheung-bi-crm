# 1986 FITNESS WONHEUNG — BI DATA CRM

고객의 최초 유입부터 누적 고객가치까지 연결하는 원흥점 관리자 1인용 데이터 수집 CRM입니다.

## 로컬 실행

```bash
npm install
npm run dev
```

현재 UI는 Supabase 연결 전 Journey 검증용 메모리 어댑터를 사용하므로 새로고침 시 입력값이 초기화됩니다. 운영 데이터는 LocalStorage에 저장하지 않습니다.

Supabase 프로젝트 생성 후 `.env.example`을 참고해 `.env.local`을 만들고 `supabase/migrations/001_initial_schema.sql`을 적용합니다. 이후 관리자 계정의 `auth.users.id`를 `public.admin_users`에 등록합니다.

전화번호 컬럼은 전체 스키마에 존재하지 않습니다.

## 배포

운영 화면은 `gh-pages` 브랜치에 게시합니다. 변경사항 검증 후 `npm run deploy`로 같은 고정 URL에 업데이트합니다.

- Production: https://1986fitnessk.github.io/1986-wonheung-bi-crm/

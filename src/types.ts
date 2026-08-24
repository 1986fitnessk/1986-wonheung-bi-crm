export type Id = string;
export type LeadStatus = '신규'|'상담예정'|'상담완료'|'방문예정'|'등록'|'보류'|'미등록'|'연락두절';
export interface Lead { id:Id; leadCode:string; firstContactDate:string; name:string; gender:string; ageGroup:string; source:string; inquiryMethod:string; goal:string; experience:string; status:LeadStatus; campaign?:string; note?:string; createdAt:string }
export interface Consultation { id:Id; consultationCode:string; leadId:Id; date:string; consultant:string; priceResistance:string; competitorStatus:string; competitor?:string; result:string; followUpNeeded:boolean; followUpDate?:string; note?:string; createdAt:string }
export interface Visit { id:Id; visitCode:string; leadId:Id; scheduledDate?:string; actualDate?:string; type:string; status:string; staff:string; tour:boolean; ptConsultation:boolean; trial:boolean; createdAt:string }
export interface Sale { id:Id; saleCode:string; leadId:Id; memberId:Id; paymentDate:string; product:string; productType:string; listPrice:number; amount:number; saleType:string; staff:string; createdAt:string }
export interface Member { id:Id; memberCode:string; leadId:Id; name:string; gender:string; ageGroup:string; joinedAt:string; source:string; status:string; createdAt:string }
export interface CrmState { leads:Lead[]; consultations:Consultation[]; visits:Visit[]; sales:Sale[]; members:Member[] }

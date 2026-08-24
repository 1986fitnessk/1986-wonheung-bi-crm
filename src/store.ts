import type { CrmState } from './types';
type Listener=()=>void;
let state:CrmState={leads:[],consultations:[],visits:[],sales:[],members:[]};
const listeners=new Set<Listener>();
export const crmStore={
 get:()=>state,
 subscribe:(fn:Listener)=>{listeners.add(fn);return()=>listeners.delete(fn)},
 add:<K extends keyof CrmState>(key:K,value:CrmState[K][number])=>{state={...state,[key]:[value,...state[key]]};listeners.forEach(fn=>fn())}
};
export const makeId=()=>crypto.randomUUID();
export const makeCode=(prefix:string,count:number)=>`${prefix}-${new Date().toISOString().slice(0,7).replace('-','')}-${String(count+1).padStart(4,'0')}`;

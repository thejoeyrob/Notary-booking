const menuToggle=document.getElementById('menuToggle');
const primaryNav=document.getElementById('primaryNav');
const API=window.INS_CONFIG.apiBase;
menuToggle?.addEventListener('click',()=>primaryNav?.classList.toggle('open'));
primaryNav?.querySelectorAll('a').forEach(a=>a.addEventListener('click',()=>primaryNav.classList.remove('open')));
if('serviceWorker' in navigator){window.addEventListener('load',()=>navigator.serviceWorker.register('sw.js').catch(()=>{}));}
async function loadPublicBusinessSettings(){
  try{
    const r=await fetch(`${API}?action=settings&public=1`,{headers:{Accept:'application/json'}});if(!r.ok)return;
    const d=await r.json(),x=d.settings||{};
    const phone=document.getElementById('publicPhone');if(phone&&x.businessPhone){phone.textContent=x.businessPhone;phone.href='tel:'+String(x.businessPhone).replace(/[^+\d]/g,'');}
    const email=document.getElementById('publicEmail');if(email&&x.businessEmail){email.textContent=x.businessEmail;email.href='mailto:'+x.businessEmail;}
    for(const id of ['googleReviewLink','footerGoogleReviewLink']){const a=document.getElementById(id);if(a&&x.googleReviewUrl)a.href=x.googleReviewUrl;}
  }catch{}
}
loadPublicBusinessSettings();

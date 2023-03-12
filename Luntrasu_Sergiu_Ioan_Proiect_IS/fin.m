clear; close all; clc;

load('iddata-06.mat');
yid=id.y;
uid=id.u;
yval=val.y;
uval=val.u;

%Plot date initiale
subplot(2,1,1);
plot(uid);
title('uid')
subplot(2,1,2);
plot(yid);
title('yid')
figure;
subplot(2,1,1);
plot(uval);
title('uval')
subplot(2,1,2);
plot(yval);
title('yval');


nk=1; %intarziere 1


for na=1:3 %for pentru ordinul sistemului
    nb=na;
    for m=1:5 %for pentru gradul polinomului
        V={}; 
        Pv=0;
        P=0;
        teta=0;
        
        %Construirea matricei de puteri
        
        P=[0:m]; 
        for i=1:length(P)
            V{1,i}=P(i);
        end
        
        
        for z=2:na+nb
            c=1;
            for i=1:length(V)
                for j=1:m+1 
                    if sum([V{z-1,i},P(j)])<=m %conditia ca suma puterilor sa fie mai mica sau egala decat gradul m
                        V{z,c}=[V{z-1,i},P(j)]; 
                        c=c+1;
                    end
                end
            end
        end
        
        
        Pv=cell(length(V));
        Pv=cell2mat(V(z,:)'); % obtinerea matricei de puteri care indeplinesc conditia necesara
        
        %Identificare
        
        X={};
        phiid=0;
        for k=1:length(yid)
            for a=1:na
                if (k-a>0)
                    X{k}(a)=-yid(k-a); %construirea lui X cu datele de identificare
                else
                    X{k}(a)=0;
                end
            end
            for b=1:nb
                if (k-nk-b+1>0)
                    X{k}(na+b)=uid(k-nk-b+1);
                else
                    X{k}(na+b)=0;
                end
            end
            
            for i=1:length(Pv)
                phiid(k,i)=prod(X{k}.^Pv(i,:));% construirea matricei phi (de regresori) pentru datele de identificare
            end
        end
        
        teta=phiid\yid; % obtinerea parametrilor modelului
        
        %Validare-Predictie
        
        X={};
        phival=0;
        
        for k=1:length(yval)
            for a=1:na
                if (k-a>0)
                    X{k}(a)=-yval(k-a); %construirea lui X cu datele de validare (iesire reala)
                else
                    X{k}(a)=0;
                end
            end
            for b=1:nb
                if (k-nk-b+1>0)
                    X{k}(na+b)=uval(k-nk-b+1);
                else
                    X{k}(na+b)=0;
                end
            end
            
            for i=1:length(Pv)
                phival(k,i)=prod(X{k}.^Pv(i,:)); %construirea matricei phi (de regresori) pentru datele de validare
            end
        end
        ypval=phival*teta; %obtinerea iesirii (predictie)
        
        er=sum((ypval-yval).^2);
        MSEpred(na,m)=1/length(yval)*er; %calcularea erorii pentru predictie si stocarea in matrice (in functie de ordin si grad)
        
        %Validare-Simulare
        
        X={};
        phivals=0;
        ysval=0;
        er=0;
        
        for k=1:length(yval)
            for a=1:na
                if (k-a>0)
                    X{k}(a)=-ysval(k-a); %construirea lui X cu datele de validare (iesire simulata)
                else
                    X{k}(a)=0;
                end
            end
            for b=1:nb
                if (k-nk-b+1>0)
                    X{k}(na+b)=uval(k-nk-b+1);
                else
                    X{k}(na+b)=0;
                end
            end
            
            for i=1:length(Pv)
                phivals(k,i)=prod(X{k}.^Pv(i,:)); %construirea matricei phi (de regresori) pentru datele de validare
            end
            
            ysval(k)=phivals(k,:)*teta; %obtinerea iesirii simulate la pasul k
            
        end
        ysval=ysval';

        er=sum((ysval-yval).^2);
        MSEsim(na,m)=1/length(yval)*er; %calcularea erorii pentru simulare si stocarea in matrice (in functie de ordin si grad)
    end
end


%Determinarea modelului cu cea mai mica eroare

min=min(MSEsim,[],'all'); 
[na,m]=find(MSEsim==min);
nb=na;

%Construirea matricei de puteri

V={};
Pv=0;
P=0;

P=[0:m];
for i=1:length(P)
    V{1,i}=P(i);
end


for z=2:na+nb
    c=1;
    for i=1:length(V)
        for j=1:m+1;
            if sum([V{z-1,i},P(j)])<=m %conditia ca suma puterilor sa fie mai mica sau egala decat gradul m
                V{z,c}=[V{z-1,i},P(j)];
                c=c+1;
            end
        end
    end
end


Pv=cell(length(V));
Pv=cell2mat(V(z,:)'); % obtinerea matricei de puteri

%Identificare

X={};
phiid=0;
for k=1:length(yid)
    for a=1:na
        if (k-a>0)
            X{k}(a)=-yid(k-a); %construirea lui X cu datele de identificare
        else
            X{k}(a)=0;
        end
    end
    for b=1:nb
        if (k-nk-b+1>0)
            X{k}(na+b)=uid(k-nk-b+1);
        else
            X{k}(na+b)=0;
        end
    end
    
    for i=1:length(Pv)
        phiid(k,i)=prod(X{k}.^Pv(i,:)); % construirea matricei phi (de regresori) pentru datele de identificare
    end
end

teta=phiid\yid; % obtinerea parametrilor modelului

%Identificare-Predictie

ypid=phiid*teta; %obtinerea iesirii (predictie)

er=sum((ypid-yid).^2);
MSEidpred=1/length(yid)*er %calcularea erorii pentru identificare-predictie

figure; %plot iesire reala si iesire predictie (identificare)
plot(yid);
hold on
plot(ypid,'r--');
title('Predictie-Identificare',MSEidpred)

%Identificare-Simulare

X={};
phiids=0;
ysid=0;
er=0;

for k=1:length(yid)
    for a=1:na
        if (k-a>0)
            X{k}(a)=-ysid(k-a); %construirea lui X cu datele de identificare (iesire simulata)
        else
            X{k}(a)=0;
        end
    end
    for b=1:nb
        if (k-nk-b+1>0)
            X{k}(na+b)=uid(k-nk-b+1);
        else
            X{k}(na+b)=0;
        end
    end
    
    for i=1:length(Pv)
        phiids(k,i)=prod(X{k}.^Pv(i,:)); % construirea matricei phi (de regresori) pentru datele de identificare (simulare)
    end
    
    ysid(k)=phiids(k,:)*teta; %obtinerea iesirii simulate la pasul k
    
end
ysid=ysid';

er=sum((ysid-yid).^2);
MSEidsim=1/length(yid)*er %calcularea erorii pentru identificare-simulare

figure; %plot iesire reala si iesire simulare (identificare)
plot(yid);
hold on;
plot(ysid,'r--');
title('Identificare-Simulare',MSEidsim);


%Validare-Predictie

X={};
phival=0;

for k=1:length(yval)
    for a=1:na
        if (k-a>0)
            X{k}(a)=-yval(k-a); %construirea lui X cu datele de validare (iesire reala)
        else
            X{k}(a)=0;
        end
    end
    for b=1:nb
        if (k-nk-b+1>0)
            X{k}(na+b)=uval(k-nk-b+1);
        else
            X{k}(na+b)=0;
        end
    end
    
    for i=1:length(Pv)
        phival(k,i)=prod(X{k}.^Pv(i,:)); % construirea matricei phi (de regresori) pentru datele de validare
    end
end
ypval=phival*teta; %obtinerea iesirii (predictie)

er=sum((ypval-yval).^2);
MSEvalpred=1/length(yval)*er %calcularea erorii pentru validare-predictie

figure; %plot iesire reala si iesire predictie (validare)
plot(yval);
hold on;
plot(ypval,'r--');
title('Validare-Predictie',MSEvalpred);

%Validare-Simulare

X={};
phivals=0;
ysval=0;
er=0;

for k=1:length(yval)
    for a=1:na
        if (k-a>0)
            X{k}(a)=-ysval(k-a); %construirea lui X cu datele de validare (iesire simulata)
        else
            X{k}(a)=0;
        end
    end
    for b=1:nb
        if (k-nk-b+1>0)
            X{k}(na+b)=uval(k-nk-b+1);
        else
            X{k}(na+b)=0;
        end
    end
    
    for i=1:length(Pv)
        phivals(k,i)=prod(X{k}.^Pv(i,:)); % construirea matricei phi (de regresori) pentru datele de validare (simulare)
    end
    
    ysval(k)=phivals(k,:)*teta; %obtinerea iesirii simulate la pasul k
    
end
ysval=ysval';

er=sum((ysval-yval).^2);
MSEvalsim=1/length(yval)*er %calcularea erorii pentru validare-simulare

figure; %plot iesire reala si iesire simulare (validare)
plot(yval);
hold on;
plot(ysval,'r--');
title('Validare-Simulare',MSEvalsim);


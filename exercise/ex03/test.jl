function deferred_acceptance(m_prefs,f_prefs)
    m = size(m_prefs, 2)
    n = size(f_prefs, 2)
    m_matched=zeros(Int64,m)
    f_matched=zeros(Int64,n)
    m_counter=zeros(Int64,m)　#ふられた回数をカウントする
    for d in 1:n+1 #全員のcounterがn+1に達するまでみたいな感じにした方がいい気がするけどやり方わからず
        for h in 1:m #1～m番までの男hに対して
            if m_matched[h] == 0　#男hが独身である場合
                if m_prefs[m_counter[h]+1,h]==0　#男hの選好で上からcounter番目が独身の時
                    m_matched[h] = 0　#もうこの人は独身で決定。

                #counter番目の選好が独身でなくちゃんと好きな人kがいるなら、その人にプロポーズする。
                
                #女kにとってhの選好が現在婚約している人より高いのであれば、婚約を破棄してhと婚約。
                elseif findfirst(f_prefs[:,m_prefs[m_counter[h]+1,h]],h) > 
                    findfirst(f_prefs[:,m_prefs[m_counter[h]+1,h]],f_matched[m_prefs[m_counter[h]+1]])
                    if f_matched[m_prefs[m_counter[h]+1,h] != 0
                        m_matched[f_matched[m_prefs[m_counter[h]+1,h]]]=0　#もともと婚約していた男は独身に
                        m_counter[f_matched[m_prefs[m_matched[h],h]]] += 1 #もともと婚約してた男のふられた回数カウンター増加。
                    end        
                    m_matched[h]=m_prefs[m_matched[h],h]　#男hはcounter番目に好きな人と婚約
                    f_matched[m_prefs[m_matched[h],h]]=h　#女kは男hと婚約
                else m_counter[h] += 1 #counter番目に好きな人kにとって男hの選好が現在婚約している人よりも低いとき、男hは独身のまま。hのふられた回数カウンター増加。
                end
            end
        end
    end
end
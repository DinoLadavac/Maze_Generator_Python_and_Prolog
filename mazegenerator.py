#Biblioteke potrebne za program
import random
#Funkcija za stvaranje labirinta
def stvori_lab(sirina, visina):
    #matrica u kojoj ce biti labirint
    lab = [] 
    for i in range(0,visina):
        red=[]
        for j in range(0,sirina):
            #Popuni matricu sa zidovima
            red.append("#") 
        lab.append(red)   
    #Odabir nasumične pozicije za početak
    trenutnix = random.randint(0, sirina-1)
    trenutniy = random.randint(0, visina-1)
    #Postavljanje praznine na nasumicnu poziciju
    lab[trenutniy][trenutnix] = " "
    #DFS algoritam
    stack=[]
    #Dodaj trenutni čvor u stog
    stack.append((trenutnix,trenutniy))
    #Dok postoji cvorova u stogu, izvodi dfs
    while stack:
        #Spremi trenunte vrijednosti x i y 
        trenutnix, trenutniy = stack.pop()
        #Susjedni cvorovi trenutnog cvora
        susjedi = [(1, 0), (-1, 0), (0, 1), (0, -1)]
        #Nasumično ih rasporedi
        random.shuffle(susjedi)
        #Siri se u svim smjerovima
        for i in susjedi:
            #Dohvati susjede susjeda
            sljedecix= trenutnix + 2* i[0] 
            sljedeciy= trenutniy + 2* i[1]
            #Provjeri ako se susjedni cvorovi nalaze unutar dimenzija te ako su oni zidovi
            if sljedecix >= 0 and sljedecix < sirina and sljedeciy >= 0 and sljedeciy < visina and lab[sljedeciy][sljedecix] == '#':
                #Susjedni cvor promjeni u prazninu
                lab[trenutniy+i[1]][trenutnix+i[0]] = " "
                #Susjedni cvor susjednog cvora promjeni u prazninu
                lab[sljedeciy][sljedecix] = " "
                #Dodaj cvor u stog
                stack.append((sljedecix, sljedeciy))

    #Dodaj ulaz i zlaz iz labirinta
    for ulaz in range(sirina):
        if lab[1][ulaz]==" ":
            lab[0][ulaz]="~"
            break
    for izlaz in reversed(range(sirina)):
        if lab[visina-2][izlaz]==" ":
            lab[visina-1][izlaz]="@"
            break
    
    #Print u str koji izgleda kao labirint
    labirint=""
    for j in lab:
        labirint += "["+",".join(j)+"]"+"\n"
    return labirint
    

#Poziv funkcije
vs=[int(x) for x in input("Unesi visinu i sirinu (pr. 25 15):").split(" ")]
print(stvori_lab(vs[0], vs[1]))
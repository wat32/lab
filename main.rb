#некоторые служебные функции
def rand_male
    ['Man','Woman'][rand(0..1)]
end

def random_string(sz = rand(20)+5)
    (0..sz).map { ('a'..'z').to_a[rand(26)]  }.join

end

def random_txt(sz = rand(40)+15)
    (0..sz).map { random_string }.join(" ")

end


#Клас ролей
# если нет переданных значений -делаем рандомные
class Role
#считаем общее количество ролей - для перехода по всем и создания имени роли
   @@count_role=0
   attr_accessor :male, :age_range, :name

   def initialize(male = rand_male, min_age = (rand(10)+10),max_age = (rand(15)+15)) 
     @male = male
     @@count_role += 1
     @age_range = (min_age..max_age).to_a
     @name ="Role_" + @@count_role.to_s + "_" + random_string(5)
   end 

   def age_valid?(age)
     age_range.include?(age)
   end

end

#задаем имя , возраст и пол


class Person
  attr_accessor :name, :age , :male 

  def initialize(name = random_string(8), age = 10+rand(20), male = rand_male) 
    @name = name
    @age = age
    @male = male
  end 

end

#Клас претендента
class Applicant < Person
  @@count_applicant=0
  attr_accessor :speech_time, :performances, :votes
  def initialize
    super
    @@count_applicant +=1
    @name ="Applicant_" + @name + "_" + @@count_applicant.to_s
    @speech_time=0
    @performances={}
    @votes={}
  end
#подходит ли роль ?
  def can_role?(role)
    raise TypeError , 'not role' if role.class == Role.class
    role.age_valid?(@age) && role.male == male
  end
#Выступление , возращается хэш и увеличиваем общее время выступлений

  def speech (role,subj = random_string , txt = random_txt , performing = 5+rand(50) )
    @speech_time += performing
    [role:role.name ,role_male:role.male ,subject:subj , txt:txt , performing:performing]
  end

  def speech_role(role)
    raise TypeError , 'not role' if role.class == Role.class
#проверяем чтобы выступление по роли было один раз и возможность выступать по этой роли
    @performances[role.name]=speech(role) if @performances[role.name].nil? && can_role?(role)
    @votes[role.name]=0
  end

end


class Referee < Person
  @@count_referee=0
  def initialize
    super
    @@count_referee +=1
    @name ="Referee_" + @name + "_" + @@count_referee.to_s
  end
  def vote(applicant,rolename)
     rl = rand(9)+1
     rl = (rand 4) + 7 if ( male == 'Man' && applicant.male == 'Woman' && (18..25).include?(applicant.age)) 
     rl = rand 7 if ( male == 'Woman' && applicant.male == 'Man' && (applicant.performances[rolename][:txt].split(' ').size <30) ) 
     [rolename,rl]
    rescue
      [rolename,0]
  end

end  
#создаем роли, соискателей и жюри

rls=(0..rand(10)+5).map{Role.new}
apl=(0..rand(10)+5).map{Applicant.new}
ref=(0..rand(10)+5).map{Referee.new}

#Для каждой роли пробуем соискателей
rls.each do |r|
  apl.each {|a| a.speech_role(r)}
end 

#проводим голосование
apl.each do |a|
  a.performances.each do |k,v|
    ref.each do |rl|
     a.votes[rl.vote(a,k)[0]]  += rl.vote(a,k)[1]
#     puts "#{k} #{a.votes[k]} #{a.name} , #{a.male} age #{a.age}"
    end  
    
  end
end
#Выводим лучшую роль и время speech
apl.each do |a|
   (rl,vt)=a.votes.max_by{|k,v| v}.to_a
   if vt > 0 then 
      puts "Applicant -> #{a.name} Role -> #{rl} Balls-> #{vt} total time to speech #{a.speech_time} "
   end
end

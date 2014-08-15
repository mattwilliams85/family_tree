class Person < ActiveRecord::Base
  validates :name, :presence => true

  after_save :make_marriage_reciprocal

  def spouse
    if spouse_id.nil?
      nil
    else
      Person.find(spouse_id)
    end
  end

  def find_siblings
    @results = []
    siblings = []
    by_mother = Person.where(mother_id: self.mother_id).where.not(mother_id: nil)
    by_father = Person.where(father_id: self.father_id).where.not(father_id: nil)
    by_mother.each { |sibling| siblings << sibling }
    by_father.each { |sibling| siblings << sibling }


    siblings = siblings.reject { |sib| sib.name == self.name}
    if siblings.length == 0
      @results << "none"
    else
      siblings.uniq.each do |sibling|

        if sibling != nil && sibling.name != self.name
          @results << sibling.name
        end
      end
    end
    @results
  end

  def find_children
    @results = []
    children = []
    by_mother = Person.where(mother_id: self.id)
    by_father = Person.where(father_id: self.id)
    by_mother.each { |child| children << child }
    by_father.each { |child| children << child }

    if children.length == 0
      @results << "none"
    else
      children.each {|child| @results << child.name}
    end
    @results
  end

  def find_cousins
    parents = []
    sibling_names = []
    siblings = []
    children_names = []
    cousins = []

    self.find_parents.each { |parent| parents << Person.find_by(name: parent)}
    parents.each { |parent| sibling_names << parent.find_siblings}
    sibling_names.flatten!
    sibling_names = sibling_names.reject { |sib| sib == "none" }
    sibling_names.each { |sib| siblings << Person.find_by(name: sib)}

    siblings.each { |sib| children_names << sib.find_children}
    children_names.flatten!
    children_names = children_names.reject { |child| child == "none" }
    children_names.each { |child| cousins << Person.find_by(name: child)}
    cousins.each {|cuz| puts "-#{cuz.name}"}
  end

  def find_auncles
    parents = []
    sibling_names = []
    siblings = []

    self.find_parents.each { |parent| parents << Person.find_by(name: parent)}
    parents.each { |parent| sibling_names << parent.find_siblings}
    sibling_names.flatten!
    sibling_names = sibling_names.reject { |sib| sib == "none" }
    sibling_names.each { |sib| siblings << Person.find_by(name: sib)}
    siblings.each {|auncle| puts "-#{auncle.name}"}
  end


  def find_parents
    @results = []
    mommy = "unknown"
    daddy = "unknown"
    mommy_object = Person.find_by(id: self.mother_id)
    daddy_object = Person.find_by(id: self.father_id)
    if self.mother_id != nil
      mommy = mommy_object.name
    end
    if self.father_id != nil
      daddy = daddy_object.name
    end
    @results << daddy
    @results << mommy
  end

  def find_marriage
    spouse = Person.find_by(id: self.spouse_id)
    if spouse == nil
      @result = "none"
    else
      @result = spouse.name
    end
    @result
  end


  def find_grandparents
    grandparents = []
    @results = []
    mom = Person.where(id: self.mother_id).first
    dad = Person.where(id: self.father_id).first

    if mom != nil
    grandparents << Person.where(id: mom.father_id).first
    grandparents << Person.where(id: mom.mother_id).first
    end
    if dad != nil
    grandparents << Person.where(id: dad.mother_id).first
    grandparents << Person.where(id: dad.father_id).first
    end


    if !grandparents.detect { |grand| grand != nil } || grandparents.length == 0
      @results << "none"
    else
      grandparents.each do |grandparent|
        if grandparent != nil
          @results << grandparent.name
        end
      end
    end
    @results
  end

private

  def make_marriage_reciprocal
    if spouse_id_changed?
      spouse.update(:spouse_id => id)
    end
  end
end

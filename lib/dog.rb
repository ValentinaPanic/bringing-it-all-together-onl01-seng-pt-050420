class Dog
    attr_accessor :name, :breed, :id

    def initialize(attributes)
     attributes.each do |key, value|
        self.send("#{key}=",value)
     end
     self.id ||= nil
    end

    def self.create_table
        sql = <<-SQL
         CREATE TABLE dogs(
             id INTEGER PRIMARY KEY,
             name TEXT,
             breed TEXT
         )
        SQL
        DB[:conn].execute(sql)
    end
    def self.drop_table
        sql = <<-SQL
         DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end
    def self.create(attributes)
        dog = Dog.new(attributes)
        dog.save
        dog
    end
    def self.new_from_db(row)
       attributes ={
            :id => row[0],
            :name => row[1],
            :breed => row[2]}
        self.new(attributes)


    end
    def self.find_by_id(id)
        sql = <<-SQL
       SELECT * FROM dogs
       WHERE id = ?
       LIMIT 1
        SQL
        DB[:conn].execute(sql,id).map do |row|
            self.new_from_db(row)
        end.first
    end
    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

        if !dog.empty?
            dog_info = dog[0]
            dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])

        else
            dog = self.create(name:name, breed:breed)
        end
        dog
    end
    def self.find_by_name(name)
        sql = <<-SQL
       SELECT * FROM dogs
       WHERE name = ?
       LIMIT 1
        SQL
        DB[:conn].execute(sql,name).map do |row|
            self.new_from_db(row)
        end.first
    end
    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def save
        if self.id
            self.update
          else
        sql = <<-SQL
         INSERT INTO dogs(name,breed)
         VALUES(?,?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
        self
          end
    end
end
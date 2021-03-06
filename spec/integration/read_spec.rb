require 'spec_helper'

describe Env, '#read' do
  include_context 'users and tasks'

  after do
    Object.send(:remove_const, :User)
    Object.send(:remove_const, :UserWithTasks) if Object.const_defined?(:UserWithTasks)
  end

  it 'exposes a relation reader' do
    rom.relations do
      users do
        def by_name(name)
          where(name: name)
        end

        def sorted
          order(:name, :email)
        end
      end
    end

    rom.mappers do
      users do
        model name: 'User'
      end
    end

    users = rom.read(:users).sorted.by_name('Jane')
    user = users.first

    expect(user).to be_an_instance_of(User)
    expect(user.name).to eql 'Jane'
    expect(user.email).to eql 'jane@doe.org'
  end

  it 'allows mapping joined relations' do
    rom.relations do
      users do
        def with_tasks
          RA.group(natural_join(tasks), tasks: [:title, :priority])
        end

        def sorted
          order(:name)
        end
      end
    end

    rom.mappers do
      users do
        model name: 'User'

        with_tasks do
          model name: 'UserWithTasks'

          group tasks: [:title, :priority]
        end
      end
    end

    User.send(:include, Equalizer.new(:name, :email))
    UserWithTasks.send(:include, Equalizer.new(:name, :email, :tasks))

    expect(rom.read(:users).with_tasks.header).to eql([:name, :email, :tasks])

    user = rom.read(:users).sorted.first

    expect(user).to eql(
      User.new(name: "Jane", email: "jane@doe.org")
    )

    user = rom.read(:users).sorted.with_tasks.first

    expect(user).to eql(
      UserWithTasks.new(name: "Jane", email: "jane@doe.org", tasks: [{ title: "be cool", priority: 2 }])
    )
  end
end

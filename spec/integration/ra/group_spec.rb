require 'spec_helper'

describe 'Group operation' do
  include_context 'users and tasks'

  specify 'defining a grouped relation' do
    rom.relations do
      users do
        def with_tasks
          RA.group(natural_join(tasks), tasks: [:title, :priority])
        end

        def by_name(name)
          where(name: name)
        end
      end
    end

    users = rom.relations.users

    expect(users.with_tasks.to_a).to eql(
      [
        {
          name: "Joe", email: "joe@doe.org", tasks: [
            { title: "be nice", priority: 1 },
            { title: "sleep well", priority: 2 }
          ]
        },
        { name: "Jane", email: "jane@doe.org", tasks: [{ title: "be cool", priority: 2 }] }
      ]
    )

    expect(users.with_tasks.by_name("Jane").to_a).to eql(
      [
        { name: "Jane", email: "jane@doe.org", tasks: [{ title: "be cool", priority: 2 }] }
      ]
    )

    expect(users.by_name("Jane").with_tasks.to_a).to eql(
      [
        { name: "Jane", email: "jane@doe.org", tasks: [{ title: "be cool", priority: 2 }] }
      ]
    )
  end
end

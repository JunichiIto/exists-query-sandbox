require 'rails_helper'
require 'benchmark'

RSpec.describe Post, type: :model do
  describe 'popular scope' do
    let(:post_count) { 100 }
    before do
      # Create posts with comments and likes
      post_count.times do |pi|
        post = Post.create!(title: "Post #{pi}")
        50.times do |ci|
          post.comments.create!(content: "Comment #{ci} for #{post.title}")
        end
        50.times do |li|
          post.likes.create!(user_name: "User #{li} for #{post.title}")
        end
      end

      # Create a post without comment and like
      Post.create!(title: 'Hidden post')
    end

    example 'benchmark' do
      posts_with_uniq = nil
      posts_with_exists = nil

      label_width = 7
      results = Benchmark.bmbm(label_width) do |x|
        x.report("Uniq:") do
          posts_with_uniq = Post.joins(:comments, :likes).distinct
          expect(posts_with_uniq.to_a.size).to eq post_count
          expect(posts_with_uniq.map(&:title)).to_not include 'Hidden post'
        end

        x.report("Exists:") do
          posts_with_exists = Post.where <<-SQL
EXISTS (SELECT * FROM comments c WHERE c.post_id = posts.id)
AND
EXISTS (SELECT * FROM likes l WHERE l.post_id = posts.id)
          SQL
          expect(posts_with_exists.to_a.size).to eq post_count
          expect(posts_with_exists.map(&:title)).to_not include 'Hidden post'
        end
      end

      diff = results[0].real / results[1].real
      puts "\nExists is #{diff.round(6)} times faster."

      puts "\nUniq:"
      puts posts_with_uniq.explain

      puts "\nExists"
      puts posts_with_exists.explain
    end
  end
end

#! /usr/bin/env ruby

# bowring.rb
# ボウリングのスコア計算（旧システム）

# frozen_string_literal: true

scores = ARGV[0].split(',')

# 標準入力を投球に変換、ストライクのフレームは2投目を0として追加
shots = []
scores.each do |s|
  if s == 'X' # ストライク
    # 10フレーム目はストライクでもフレームを続行
    shots << 10
    shots << 0 if shots.size < 9 * 2
  else
    shots << s.to_i
  end
end
p shots

# 全投球をフレームごとに分割
# 10フレーム目だけ3投になる
frames = []
shots.each_slice(2) do |s|
  frames << s
end
if frames[10]
  frames[9] = frames[9] + frames[10]
  frames.delete_at(10)
end
p frames
# 得点計算
point = 0
next1 = 0
next2 = 0
frames.reverse_each do |frame|
  p point
  if frame.size == 3 # 3投してる10フレーム目
    point += frame.sum
    next2 = frame[1]
    next1 = frame[0]
  elsif frame[0] == 10 # strike
    point += 10 + next1 + next2
    next2 = next1
    next1 = 10
  elsif frame.sum == 10 # spare
    point += 10 + next1
    next2 = frame[1]
    next1 = frame[0]
  else
    point += frame.sum
    next2 = frame[1]
    next1 = frame[0]
  end
end

puts point

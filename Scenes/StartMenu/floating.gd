extends AnimatedSprite2D

# 悬浮参数
@export var max_offset: Vector2 = Vector2(50, 40)    # 最大偏移量（像素）
@export var float_speed: float = 0.3                 # 漂浮速度系数
@export var noise_frequency: float = 0.3             # 噪声频率，影响变化平滑度

var center_position: Vector2                         # 初始中心位置
var noise: FastNoiseLite                             # 噪声实例
var time: float = 0.0                                # 用于噪声采样的时间变量

func _ready():
	# 记录初始位置作为中心点
	center_position = position
	# 初始化噪声实例
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN     # 使用 Perlin 噪声产生平滑变化
	noise.seed = randi()                             # 设置随机种子以确保每次运行效果不同
	noise.frequency = noise_frequency                # 设置噪声频率

func _process(delta):
	# 更新时间，乘以速度系数控制变化快慢
	time += delta * float_speed

	# 使用二维噪声获取平滑的随机偏移值（范围大致在[-1, 1]）
	var x_noise = noise.get_noise_2d(time, 0)        # 对X轴采样
	var y_noise = noise.get_noise_2d(0, time)        # 对Y轴采样

	# 将噪声值缩放到设定的最大偏移范围内
	var current_offset = Vector2(
		x_noise * max_offset.x,
		y_noise * max_offset.y
	)

	# 更新精灵位置：中心位置 + 计算出的偏移量
	position = center_position + current_offset

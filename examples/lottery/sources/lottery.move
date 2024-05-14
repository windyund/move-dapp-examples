/// Module: lottery
module lottery::lottery {
    use std::debug;
    use std::vector;
    use std::option;
    use std::option::{Option, some};
    use std::vector::{ push_back};
    use sui::address;
    use sui::balance::{Self, Balance, zero};
    use sui::bcs;
    use sui::clock::{Self,Clock, timestamp_ms};
    use sui::coin::{Self, Coin, value};
    use sui::hash::blake2b256;
    use sui::object;
    use sui::object::{UID, ID};
    use sui::package;
    use sui::sui::SUI;
    use sui::transfer::{transfer, share_object, public_transfer};
    use sui::tx_context;
    use sui::tx_context::TxContext;
    use oracle::weather::{WeatherOracle};
    use lottery::utils;

   public struct Lottery has key,store {
        id:UID,
        reward_pool: Balance<SUI>, //奖励池
        publisher: address,        //发布者
        price: u64,                //彩票价格,MIST，即最小单位
        start_time: u64,           //开始时间
        end_time: u64,             //截止时间
        status: u8,                //状态
        ticket_num: u64,           //彩票数量，也用于最后抽奖判断范围：1-ticket_num范围内随机抽取
        player_num: u64,           //参与者数量，统计address num
        winner: Option<address>,   //获奖者
        winner_ticket: Option<u64>,//获奖的票据对应数字
        winner_claimed: bool,      //是否领奖
        fee_ratio: u64,            //手续费比例
    }


   public struct Ticket has key, store {
        id:UID,
        lottery_id: ID,
        tickets: vector<u64>  // 票据
    }

    // 管理员权限
    public  struct AdminCap has key, store{
        id :UID
    }

    //============== wintess ==============
    public struct LOTTERY has drop {}

    // ============== Constants ==============
    const ACTIVE:u8 = 1;
    const ENDED: u8 = 2;


    // ============== Errors ==============

    const ELotteryHasEnded:u64 = 1;
    const EAmountNotEnough:u64 = 2;
    const ELotteryNotEnd:u64 = 3;
    const ELotteryStatusNotValid: u64 = 4;
    const EClaimNotRight: u64 = 4;


    // 构造函数，单例
    fun init(otw: LOTTERY, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let publisher = package::claim(otw, ctx);
        let adminCap = AdminCap { id: object::new(ctx) };
        transfer(adminCap, sender);
        public_transfer(publisher, sender);
    }

    // 创建彩票,仅发布者可调
    public entry fun create_lottory(_: &AdminCap, price: u64, duration: u64, feeRatio:u64, clock: &Clock, ctx: &mut TxContext) {
        let current_time =timestamp_ms(clock);
        let lottery = Lottery{
            id: object::new(ctx),
            reward_pool: zero<SUI>(),
            publisher: tx_context::sender(ctx),
            price,
            start_time: current_time,
            end_time: current_time+ duration,
            status: ACTIVE,
            ticket_num: 0,
            player_num: 0,
            winner: option::none(),
            winner_ticket: option::none(),
            winner_claimed: false,
            fee_ratio: feeRatio
        };
        share_object(lottery);
    }

    // 找零
    fun spilt_coin(needPay: u64, payAmount: u64, mut payCoin:  Coin<SUI>, ctx: &mut TxContext): Coin<SUI> {
        if (payAmount > needPay) {
            let paid = coin::split(&mut payCoin, needPay, ctx);
            public_transfer(payCoin, tx_context::sender(ctx));
            return paid
        };
        payCoin
    }


    // 购买彩票
    public entry fun buy_lottory(lottery: &mut Lottery, ticketNum: u64, amount: Coin<SUI>, clock:&Clock, ctx: &mut TxContext) {
        //判断是否在时间范围内
        let cur_time =  timestamp_ms(clock);
        assert!(cur_time> lottery.start_time && cur_time < lottery.end_time, ELotteryHasEnded);
        //付款是否大于票价
        let  require_amount =  lottery.price * ticketNum;
        let  payVal =  value(&amount);
        assert!(payVal >= require_amount, EAmountNotEnough);
        //找零, amount 转移所有权
        let pay_coin = spilt_coin(require_amount, payVal, amount, ctx);
        // get lottery id
        let lotteryId = object::uid_to_inner(&lottery.id);
        let mut i  = 1;
        let old_ticket_num =  lottery.ticket_num;
        let mut tickets = vector::empty<u64>();
        while (i <= ticketNum) {
             push_back(&mut tickets, old_ticket_num  + 1);
             i = i+1;
        };
        lottery.ticket_num = old_ticket_num + ticketNum;
        lottery.player_num = lottery.player_num + 1;
        let coin_balance =  coin::into_balance(pay_coin);
        balance::join(&mut lottery.reward_pool, coin_balance);
        //ticket对象
       let  ticket =  Ticket{
            id:object::new(ctx),
            lottery_id: lotteryId,
            tickets:tickets
        };
        transfer(ticket,tx_context::sender(ctx));
    }

    // 开奖:生成随机数
    public entry fun endLottery(weather_oracle: &WeatherOracle,  lottery: &mut Lottery, clock:&Clock, ctx: &TxContext) {
        assert!(lottery.status == ACTIVE, ELotteryStatusNotValid);
        let current_time = timestamp_ms(clock);
        assert!(current_time > lottery.end_time, ELotteryNotEnd);
        let random = get_random(weather_oracle, lottery.ticket_num, clock, ctx);
        lottery.winner_ticket  = some(random);
        lottery.status = ENDED
    }



    // 获取随机数
    fun get_random(weather_oracle: &WeatherOracle, max: u64, clock: &Clock, ctx: &TxContext): u64 {
        let sender = tx_context::sender(ctx);
        let tx_digest = tx_context::digest(ctx);
        let random_pressure_p = oracle::weather::city_weather_oracle_pressure(weather_oracle, 2988507);// Paris, France
        let random_pressure_p_2 = oracle::weather::city_weather_oracle_pressure(weather_oracle, 2147714);//Sydney
        let random_temp = oracle::weather::city_weather_oracle_temp(weather_oracle, 1785286);//Zibo,CN

        let mut random_vector = vector::empty<u8>();
        vector::append(&mut random_vector, address::to_bytes(copy sender));
        vector::append(&mut random_vector, utils::u32_to_ascii(random_pressure_p));
        vector::append(&mut random_vector, utils::u32_to_ascii(random_pressure_p_2));
        vector::append(&mut random_vector, utils::u32_to_ascii(random_temp));
        vector::append(&mut random_vector, utils::u64_to_ascii(clock::timestamp_ms(clock)));
        vector::append(&mut random_vector, *copy tx_digest);

        let temp1 = blake2b256(&random_vector);
        let random_num_ex = bcs::peel_u64(&mut bcs::new(temp1));
        let random_value = ((random_num_ex % max) as u64);
        debug::print(&random_value);
        random_value
    }


    // 领取彩票
    public entry fun claimLottery(ticket: &Ticket, lottery: &mut Lottery, ctx: &mut TxContext) {
        assert!(lottery.status == ENDED, ELotteryStatusNotValid);
        assert!(vector::contains(&ticket.tickets, option::borrow(&lottery.winner_ticket)), EClaimNotRight);

        let sender = tx_context::sender(ctx);
        lottery.winner = some(sender);
        lottery.winner_claimed = true;
        //
        let pool_val = balance::value(&lottery.reward_pool);
        let leftCoin = coin::take(&mut lottery.reward_pool, pool_val, ctx);
        public_transfer(leftCoin, sender);
    }


    //管理员提现收益
    public entry fun withdraw(_: &AdminCap, lottery: &mut Lottery, ctx: &mut TxContext) {
        let pool_val = balance::value(&lottery.reward_pool);
        let leftCoin = coin::take(&mut lottery.reward_pool, pool_val, ctx);
        public_transfer(leftCoin, tx_context::sender(ctx));
    }
}

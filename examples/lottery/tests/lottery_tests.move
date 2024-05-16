#[test_only]
#[allow(duplicate_alias)]
module lottery::lottery_tests {

    use sui::clock::{Self, Clock};
    use sui::coin;
    use sui::sui::SUI;
    use lottery::lottery::{Self, Lottery, price, buy_lottory, AdminCap};
    use sui::test_scenario as ts;
    use sui::test_scenario::sender;

    const Player1: address = @0xA;
    const Player2: address = @0xB;
    const Player3: address = @0xC;
    const ENotImplemented: u64 = 0;


    #[test_only]
    public fun testBuyTickets(ts: &mut ts::Scenario, sender: address, noOfTickets: u64, clock: &Clock) {
        ts::next_tx(ts, sender);
        let mut lottery = ts::take_shared<Lottery>(ts);
        let ticketPrice = price(&lottery);
        let amountToPay = ticketPrice * noOfTickets;
        let amountCoin = coin::mint_for_testing<SUI>(amountToPay, ts::ctx(ts));
        buy_lottory(&mut lottery, noOfTickets, amountCoin, clock, ts::ctx(ts));
        ts::return_shared(lottery);
    }

    #[test]
    fun test_lottery_game() {
        let mut ts = ts::begin(@0x0);
        let mut clock = clock::create_for_testing(ts::ctx(&mut ts));

        //init
        lottery::create_admin_for_testing(ts::ctx(&mut ts));

        ts::next_tx(&mut ts, @0x0);
        let admin = ts::take_from_sender<AdminCap>(&ts);

        // start lottery
        {
            ts::next_tx(&mut ts, @0x0);

            let ticketPrice: u64 = 2; // 2 sui
            let lotteryDuration: u64 = 50; // 50 ticks

            lottery::create_lottory(&admin, ticketPrice, lotteryDuration, 0, &clock, ts::ctx(&mut ts));
        };

        // buy tickets for player1, player2, player3
        {
            clock::increment_for_testing(&mut clock, 20);
            testBuyTickets(&mut ts, Player1, 30, &clock);
            testBuyTickets(&mut ts, Player2, 20, &clock);
            testBuyTickets(&mut ts, Player3, 10, &clock);
        };

        // increase time to lottery end
        {
            ts::next_tx(&mut ts, @0x0);
            clock::increment_for_testing(&mut clock, 55);
        };


        clock::destroy_for_testing(clock);
        ts::return_to_sender(&ts, admin);
        ts::end(ts);
    }



    //测试预期异常
    #[test]
    #[expected_failure(abort_code =ENotImplemented)]
    fun test_lottery_fail() {
        abort ENotImplemented
    }
}

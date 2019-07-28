function done=clipit(what,onto)
done=onto*(what>onto)+what.*(what<=onto);
done=-onto*(done<-onto)+done.*(done>=(-onto));